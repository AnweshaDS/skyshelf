//
//  ProfileView.swift
//  SkyShelf
//
//  Created by macos on 26/11/26.
//

import SwiftUI

// Profile screen: shows the account email and lets the user change the password
struct ProfileView: View {

    @EnvironmentObject var auth: AuthManager

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var message = ""          // text shown under the form
    @State private var isSuccess = false     // green message or red message
    @State private var isWorking = false     // true while Firebase is busy

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Account info
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.purple)
                    Text(auth.user?.email ?? "")
                        .font(.headline)
                }
                .padding(.top, 10)

                // Change password form
                VStack(alignment: .leading, spacing: 12) {
                    Text("Change password")
                        .font(.title3)
                        .fontWeight(.semibold)

                    SecureField("Current password", text: $oldPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("New password (min 6 characters)", text: $newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Confirm new password", text: $confirmPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    // Success or error message
                    if !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(isSuccess ? .green : .red)
                    }

                    Button {
                        save()
                    } label: {
                        HStack {
                            if isWorking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isWorking ? "Please wait..." : "Update password")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isWorking)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Check the inputs first, then ask Firebase
    private func save() {
        isSuccess = false

        if oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            message = "Please fill in all three boxes."
            return
        }
        if newPassword.count < 6 {
            message = "The new password must be at least 6 characters."
            return
        }
        if newPassword != confirmPassword {
            message = "The new password and the confirmation do not match."
            return
        }
        if newPassword == oldPassword {
            message = "The new password must be different from the current one."
            return
        }

        message = ""
        isWorking = true
        auth.changePassword(oldPassword: oldPassword, newPassword: newPassword) { error in
            isWorking = false
            if let error = error {
                isSuccess = false
                message = error
            } else {
                isSuccess = true
                message = "Password updated successfully."
                oldPassword = ""
                newPassword = ""
                confirmPassword = ""
            }
        }
    }
}
