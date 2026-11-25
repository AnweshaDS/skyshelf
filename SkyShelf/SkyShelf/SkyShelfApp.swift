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

    // @StateObject: the app owns these objects for its whole life
    @StateObject private var auth: AuthManager
    @StateObject private var favorites: FavoritesService

    init() {
        // Firebase must be configured BEFORE the objects that use it are created
        FirebaseApp.configure()
        _auth = StateObject(wrappedValue: AuthManager())
        _favorites = StateObject(wrappedValue: FavoritesService())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // @EnvironmentObject: every screen below can read these
                .environmentObject(auth)
                .environmentObject(favorites)
        }
    }
}
