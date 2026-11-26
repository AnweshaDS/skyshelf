//
//  AuthManager.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation
import FirebaseAuth

// ObservableObject: any view watching this object redraws when a @Published value changes.
class AuthManager: ObservableObject {

    @Published var user: User?            // nil means logged out
    @Published var errorMessage = ""      // shown on the login screen
    @Published var isLoading = false      // true while waiting for Firebase

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Start with whoever is already logged in (if anyone)
        user = Auth.auth().currentUser

        // Firebase calls this every time the user logs in or out
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Create a new account
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyMessage(for: error) ?? ""
                }
            }
        }
    }

    // Log in to an existing account
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyMessage(for: error) ?? ""
                }
            }
        }
    }

    // Log out
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = "Could not log out. Please try again."
        }
    }

    // Change the password.
    // Step 1: prove the old password (reauthenticate).
    // Step 2: set the new password.
    // The completion gets nil on success, or a message to show on failure.
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser,
              let email = currentUser.email else {
            completion("You are not logged in.")
            return
        }

        // A credential is the email and the old password packed together
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        currentUser.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self?.passwordChangeMessage(for: error))
                }
                return
            }

            // The old password was correct, so set the new one
            currentUser.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(self?.passwordChangeMessage(for: error))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    // Messages for the change password form
    private func passwordChangeMessage(for error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case 17009, 17004: return "Your current password is wrong."
        case 17026:        return "The new password is too weak. Use at least 6 characters."
        case 17010:        return "Too many attempts. Please wait and try again."
        case 17020:        return "No internet connection. Check your network."
        case 17014:        return "Please log out, log in again and retry."
        default:           return "Could not change the password. Please try again."
        }
    }

    // Turn Firebase error codes into short readable messages
    private func friendlyMessage(for error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case 17007: return "This email is already registered. Try logging in."
        case 17008: return "That email address is not valid."
        case 17009: return "Wrong password. Please try again."
        case 17011: return "No account found with this email."
        case 17004: return "Email or password is incorrect."
        case 17026: return "Password is too weak. Use at least 6 characters."
        case 17010: return "Too many attempts. Please wait and try again."
        case 17020: return "No internet connection. Check your network."
        default:    return "Something went wrong. Please try again."
        }
    }
}
