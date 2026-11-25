//
//  SkyShelfApp.swift
//  SkyShelf
//
//  Created by macos on 24/11/26.
//

import SwiftUI
import FirebaseCore

@main
struct SkyShelfApp: App {

    // @StateObject: this app owns one AuthManager for its whole life
    @StateObject private var auth: AuthManager

    init() {
        // Firebase must be configured BEFORE AuthManager is created
        FirebaseApp.configure()
        _auth = StateObject(wrappedValue: AuthManager())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // @EnvironmentObject: every screen below can read "auth"
                .environmentObject(auth)
        }
    }
}
