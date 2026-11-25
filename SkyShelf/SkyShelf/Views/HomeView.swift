//
//  HomeView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var auth: AuthManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                Text("You are logged in")
                    .font(.title2)
                Text(auth.user?.email ?? "")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("SkyShelf")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        auth.signOut()
                    }
                }
            }
        }
    }
}
