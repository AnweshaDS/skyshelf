//
//  APODRowView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// One row of the recent gallery: thumbnail, title and date, in a card
struct APODRowView: View {

    let item: APODItem

    var body: some View {
        HStack(spacing: 12) {
            APODImageView(url: item.displayImageURL, height: 80)
                .frame(width: 100)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Label(item.date, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !item.isImage {
                    Label("Video", systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
