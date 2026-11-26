//
//  APODImageView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI
import UIKit

// The three phases of loading a picture
private enum LoadState {
    case loading
    case success(UIImage)
    case failure
}

// Shows a picture from a URL and handles every phase:
// loading, success and failure. Also handles "no URL".
struct APODImageView: View {

    let url: URL?
    var height: CGFloat = 200

    // Current phase. It starts as "loading".
    @State private var state: LoadState = .loading

    var body: some View {
        // The clear box decides the size (full width, fixed height).
        // The picture is drawn on top of it and clipped, so a big picture
        // can never make the screen wider than the phone.
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(content)
            .clipped()
            .cornerRadius(12)
            // Runs when the view appears, and again if the url changes
            .task(id: url) {
                guard let url = url else { return }
                state = .loading
                state = await APODImageView.download(url)
            }
    }

    // What is drawn inside the box
    @ViewBuilder
    private var content: some View {
        if url == nil {
            placeholder("No preview available")
        } else {
            switch state {
            case .loading:
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                }
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder("Image could not be loaded")
            }
        }
    }

    // Downloads the picture with URLSession and turns the data into a UIImage
    private static func download(_ url: URL) async -> LoadState {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("image/jpeg,image/png,image/*;q=0.8", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                return .failure
            }
            if let image = UIImage(data: data) {
                return .success(image)
            }
            return .failure
        } catch {
            return .failure
        }
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
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}
