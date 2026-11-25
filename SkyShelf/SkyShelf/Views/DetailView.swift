//
//  DetailView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// Full screen for one picture
struct DetailView: View {

    let item: APODItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Image (or thumbnail / placeholder for videos)
                APODImageView(url: item.displayImageURL, height: 300)

                // Videos (and other non-image days) cannot be shown here,
                // so offer a link that opens the original page
                if !item.isImage, let link = URL(string: item.url) {
                    Link(destination: link) {
                        Label("Open video", systemImage: "play.rectangle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(item.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Copyright only exists on some days
                if let credit = item.cleanCopyright {
                    Text("Credit: \(credit)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // HD version only exists on some days
                if let hd = item.hdurl, let hdLink = URL(string: hd) {
                    Link("Open HD image", destination: hdLink)
                        .font(.subheadline)
                }

                Divider()

                Text(item.explanation)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
