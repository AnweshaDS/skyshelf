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

    // Runs once when the app starts. Firebase must be configured first.
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
