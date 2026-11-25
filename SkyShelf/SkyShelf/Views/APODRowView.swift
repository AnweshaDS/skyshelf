//
//  APODRowView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// One row of the recent gallery: thumbnail, title and date
struct APODRowView: View {

    let item: APODItem

    var body: some View {
        HStack(spacing: 12) {
            APODImageView(url: item.displayImageURL, height: 70)
                .frame(width: 90)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !item.isImage {
                    Label("Video", systemImage: "play.circle")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
