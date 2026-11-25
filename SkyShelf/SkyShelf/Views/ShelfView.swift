//
//  ShelfView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// The user's saved pictures, live from Firestore
struct ShelfView: View {

    @EnvironmentObject var favorites: FavoritesService

    @State private var searchText = ""

    // The list after applying the title search
    private var filtered: [FavoriteItem] {
        let text = searchText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            return favorites.favorites
        }
        return favorites.favorites.filter { $0.title.localizedCaseInsensitiveContains(text) }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Search box
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search by title", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding()

            if !favorites.errorMessage.isEmpty {
                Text(favorites.errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // Show the right thing for each situation
            if !favorites.isLoaded {
                Spacer()
                ProgressView("Loading your shelf...")
                Spacer()
            } else if favorites.favorites.isEmpty {
                emptyState(icon: "heart.slash",
                           title: "No favorites yet",
                           subtitle: "Open a picture and tap the heart to save it here.")
            } else if filtered.isEmpty {
                emptyState(icon: "magnifyingglass",
                           title: "No matches",
                           subtitle: "No saved picture has that word in its title.")
            } else {
                List {
                    ForEach(filtered) { item in
                        row(item)
                            // Swipe left to delete
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    favorites.remove(date: item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Shelf")
        .navigationBarTitleDisplayMode(.inline)
        // Start the live listener when the screen appears ...
        .onAppear {
            favorites.startListening()
        }
        // ... and remove it when the screen disappears
        .onDisappear {
            favorites.stopListening()
        }
    }

    // One row: thumbnail, title, date, note preview
    private func row(_ item: FavoriteItem) -> some View {
        HStack(spacing: 12) {
            APODImageView(url: URL(string: item.imageURL), height: 70)
                .frame(width: 90)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.id)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !item.note.isEmpty {
                    Label(item.note, systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // Message shown when there is nothing to list
    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.purple.opacity(0.6))
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }
}
