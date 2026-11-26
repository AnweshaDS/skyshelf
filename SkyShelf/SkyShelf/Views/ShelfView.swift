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

    // Note editing: which picture is selected and the text being edited
    @State private var selected: FavoriteItem?
    @State private var noteText = ""

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
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            .padding()

            if !favorites.errorMessage.isEmpty {
                Text(favorites.errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // How many pictures are shown
            if favorites.isLoaded && !favorites.favorites.isEmpty {
                HStack {
                    Text("\(filtered.count) of \(favorites.favorites.count) pictures")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
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
                            .contentShape(Rectangle())
                            // Tap a card to open the note editor
                            .onTapGesture {
                                noteText = item.note
                                selected = item
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
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
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("My Shelf")
        .navigationBarTitleDisplayMode(.inline)
        // Note editor sheet. It opens when "selected" gets a value.
        .sheet(item: $selected) { item in
            NoteEditorView(
                title: item.title,
                note: $noteText,
                onSave: {
                    favorites.updateNote(date: item.id, note: noteText)
                },
                onDelete: {
                    favorites.updateNote(date: item.id, note: "")
                }
            )
        }
        // Start the live listener when the screen appears ...
        .onAppear {
            favorites.startListening()
        }
        // ... and remove it when the screen disappears
        .onDisappear {
            favorites.stopListening()
        }
    }

    // One card: thumbnail, title, date, note preview
    private func row(_ item: FavoriteItem) -> some View {
        HStack(spacing: 12) {
            APODImageView(url: URL(string: item.imageURL), height: 80)
                .frame(width: 100)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Label(item.id, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if item.note.isEmpty {
                    Label("Tap to add a note", systemImage: "square.and.pencil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Label(item.note, systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
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
