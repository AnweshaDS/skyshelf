//
//  APODItem.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation

// One NASA picture of the day.
// Codable: can be built straight from JSON.
// Identifiable: SwiftUI lists need a unique id (the date is unique).
struct APODItem: Codable, Identifiable {
    let date: String
    let title: String
    let explanation: String
    let url: String
    let hdurl: String?          // optional: missing on some days
    let mediaType: String       // "image" or "video"
    let copyright: String?      // optional
    let thumbnailUrl: String?   // only for videos (we ask for thumbs=true)

    var id: String { date }

    // CodingKeys connect JSON names (media_type) to Swift names (mediaType)
    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url, hdurl, copyright
        case mediaType = "media_type"
        case thumbnailUrl = "thumbnail_url"
    }

    // True when this day is a normal picture
    var isImage: Bool {
        return mediaType == "image"
    }

    // The picture we can show: the image itself, or the thumbnail for a video.
    // http is changed to https because iOS blocks plain http.
    var displayImageURL: URL? {
        let text: String? = isImage ? url : thumbnailUrl
        guard let text = text else { return nil }
        return URL(string: text.replacingOccurrences(of: "http://", with: "https://"))
    }

    // Copyright can contain line breaks, so clean it. nil if empty.
    var cleanCopyright: String? {
        guard let text = copyright else { return nil }
        let cleaned = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}
