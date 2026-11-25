//
//  APODImageView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// Shows a picture from a URL and handles every AsyncImage phase:
// loading (empty), success and failure. Also handles "no URL".
struct APODImageView: View {

    let url: URL?
    var height: CGFloat = 200

    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // still loading
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder("Image could not be loaded")
                    @unknown default:
                        placeholder("No preview available")
                    }
                }
            } else {
                placeholder("No preview available")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .cornerRadius(12)
    }

    // Grey box with an icon (and text when there is enough room)
    private func placeholder(_ text: String) -> some View {
        ZStack {
            Color.gray.opacity(0.2)
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.title2)
                if height >= 150 {
                    Text(text)
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}
