//
//  AuthView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

struct AuthView: View {

    @EnvironmentObject var auth: AuthManager   // shared login manager

    @State private var isSignUp = false        // false = Log In, true = Sign Up
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Space-style gradient background
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.25),
                         Color(red: 0.35, green: 0.15, blue: 0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Title area
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        Text("SkyShelf")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Your personal NASA space gallery")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)

                    // Form card
                    VStack(spacing: 16) {
                        Text(isSignUp ? "Create account" : "Welcome back")
                            .font(.title2)
                            .fontWeight(.semibold)

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                        SecureField("Password (min 6 characters)", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                        // Error message (validation or Firebase)
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Main button
                        Button {
                            submit()
                        } label: {
                            HStack {
                                if auth.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(auth.isLoading ? "Please wait..." : (isSignUp ? "Sign Up" : "Log In"))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(auth.isLoading)

                        // Switch between Log In and Sign Up
                        Button {
                            isSignUp.toggle()
                            auth.errorMessage = ""
                        } label: {
                            Text(isSignUp ? "Already have an account? Log In" : "New here? Sign Up")
                                .font(.footnote)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // Check the inputs first, then call Firebase
    private func submit() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanEmail.isEmpty || password.isEmpty {
            auth.errorMessage = "Please enter your email and password."
            return
        }
        if !cleanEmail.contains("@") || !cleanEmail.contains(".") {
            auth.errorMessage = "Please enter a valid email address."
            return
        }
        if password.count < 6 {
            auth.errorMessage = "Password must be at least 6 characters."
            return
        }

        if isSignUp {
            auth.signUp(email: cleanEmail, password: password)
        } else {
            auth.signIn(email: cleanEmail, password: password)
        }
    }
}
