//
//  HomeView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var auth: AuthManager
    @State private var message = "Loading..."

    var body: some View {
        NavigationStack {
            Text(message)
                .padding()
                .navigationTitle("SkyShelf")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") { auth.signOut() }
                    }
                }
                .onAppear { test() }
        }
    }

    // Temporary: checks that the API works
    @MainActor
    func test() {
        Task {
            do {
                let item = try await APODService().fetchToday()
                let list = try await APODService().fetchRange(
                    start: DateHelper.addDays(-10, to: item.date),
                    end: DateHelper.addDays(-1, to: item.date))
                message = "Today: \(item.title)\nGallery items: \(list.count)"
            } catch let error as APODError {
                message = error.message
            } catch {
                message = "Something went wrong."
            }
        }
    }
}
