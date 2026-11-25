//
//  RootView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// Decides which screen to show: login screen or the app
struct RootView: View {

    @EnvironmentObject var auth: AuthManager

    var body: some View {
        if auth.user != nil {
            HomeView()
        } else {
            AuthView()
        }
    }
}
