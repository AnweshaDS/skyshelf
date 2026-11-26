//
//  DetailView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// Full screen for one picture, with a heart button to save it
struct DetailView: View {

    @EnvironmentObject var favorites: FavoritesService

    let item: APODItem

    @State private var isSaved = false       // is the heart filled?
    @State private var isWorking = false     // blocks double taps
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Image (or preview / placeholder for videos)
                APODImageView(url: item.displayImageURL, height: 320)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                // Videos cannot be shown here, so offer a link to the original page
                if !item.isImage, let link = URL(string: item.url) {
                    Link(destination: link) {
                        Label("Open video", systemImage: "play.rectangle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                // Title, date and credit
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 14) {
                        Label(item.date, systemImage: "calendar")
                            .foregroundColor(.secondary)
                        if !item.isImage {
                            Label("Video", systemImage: "play.circle.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .font(.subheadline)

                    // Copyright only exists on some days
                    if let credit = item.cleanCopyright {
                        Label(credit, systemImage: "camera")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                // HD version only exists on some days
                if let hd = item.hdurl, let hdLink = URL(string: hd) {
                    Link(destination: hdLink) {
                        Label("Open HD image", systemImage: "arrow.up.right.square")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.purple.opacity(0.12))
                            .foregroundColor(.purple)
                            .cornerRadius(10)
                    }
                }

                // The explanation, inside a card
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this picture")
                        .font(.headline)
                    Text(item.explanation)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
                .disabled(isWorking)
            }
        }
        .alert("Favorites", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Fill or empty the heart depending on what is saved
            favorites.checkSaved(date: item.date) { saved in
                isSaved = saved
            }
        }
    }

    // Heart tapped: add if not saved, remove if saved
    private func toggleFavorite() {
        isWorking = true
        if isSaved {
            favorites.remove(date: item.date) { success in
                if success {
                    isSaved = false
                } else {
                    alertMessage = "Could not remove this picture. Check your connection."
                    showAlert = true
                }
                isWorking = false
            }
        } else {
            favorites.add(item: item) { success in
                if success {
                    isSaved = true
                } else {
                    alertMessage = "Could not save this picture. Check your connection."
                    showAlert = true
                }
                isWorking = false
            }
        }
    }
}
