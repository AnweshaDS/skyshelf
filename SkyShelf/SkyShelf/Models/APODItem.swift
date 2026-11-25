//
//  APODItem.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation

// One NASA picture of the day.
// Decodable: can be built straight from JSON.
// Identifiable: SwiftUI lists need a unique id (the date is unique).
struct APODItem: Decodable, Identifiable {
    let date: String
    let title: String
    let explanation: String
    let url: String             // the image, or the page to open for a video
    let hdurl: String?          // optional: missing on some days
    let mediaType: String       // "image" or "video"
    let copyright: String?      // optional
    let thumbnailUrl: String?   // preview picture for a video day (if any)

    var id: String { date }

    // CodingKeys connect JSON names (media_type) to Swift names (mediaType)
    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url, hdurl, copyright, credit, permalink
        case mediaType = "media_type"
    }

    // We build the item by hand because the new NASA API sends text with HTML tags
    // and the video days need a little extra care.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        date = try c.decode(String.self, forKey: .date)

        let rawTitle = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        title = APODItem.cleanText(rawTitle)

        let rawExplanation = try c.decodeIfPresent(String.self, forKey: .explanation) ?? ""
        explanation = APODItem.cleanText(rawExplanation)

        let type = try c.decodeIfPresent(String.self, forKey: .mediaType) ?? "image"
        mediaType = type

        let rawUrl = try c.decodeIfPresent(String.self, forKey: .url) ?? ""
        let rawHd = try c.decodeIfPresent(String.self, forKey: .hdurl)
        let page = try c.decodeIfPresent(String.self, forKey: .permalink)

        let copyrightText = try c.decodeIfPresent(String.self, forKey: .copyright)
        let creditText = try c.decodeIfPresent(String.self, forKey: .credit)
        copyright = copyrightText ?? creditText

        hdurl = rawHd

        if type == "image" {
            url = rawUrl
            thumbnailUrl = nil
        } else if APODItem.isImageLink(rawUrl) {
            // video day, but the url is a picture: use it as the preview
            // and open the NASA page when the user taps "Open video"
            thumbnailUrl = rawUrl
            url = page ?? rawUrl
        } else if let hd = rawHd, APODItem.isImageLink(hd) {
            thumbnailUrl = hd
            url = rawUrl
        } else {
            thumbnailUrl = nil
            url = rawUrl
        }
    }

    // True when this day is a normal picture
    var isImage: Bool {
        return mediaType == "image"
    }

    // The picture we can show: the image itself, or the preview for a video.
    // http is changed to https because iOS blocks plain http.
    var displayImageURL: URL? {
        let text: String? = isImage ? url : thumbnailUrl
        guard let text = text, !text.isEmpty else { return nil }
        return URL(string: text.replacingOccurrences(of: "http://", with: "https://"))
    }

    // Credit text without the leading word "Credit:" and without line breaks.
    // nil if empty.
    var cleanCopyright: String? {
        guard let text = copyright else { return nil }
        var cleaned = APODItem.cleanText(text)
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("Credit:") {
            cleaned = String(cleaned.dropFirst(7)).trimmingCharacters(in: .whitespaces)
        }
        return cleaned.isEmpty ? nil : cleaned
    }

    // Does this link end in a picture file type?
    private static func isImageLink(_ text: String) -> Bool {
        guard let link = URL(string: text) else { return false }
        let ext = link.pathExtension.lowercased()
        return ["jpg", "jpeg", "png", "gif"].contains(ext)
    }

    // The new API sends HTML. Turn it into plain text.
    private static func cleanText(_ html: String) -> String {
        var text = html
        // line breaks and paragraph ends become new lines
        text = text.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n")
        // remove every other tag, for example <strong> and <a href="...">
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // common HTML symbols
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#8217;", with: "'")
        text = text.replacingOccurrences(of: "&#8216;", with: "'")
        text = text.replacingOccurrences(of: "&#039;", with: "'")
        text = text.replacingOccurrences(of: "&#8211;", with: "-")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        // more than two empty lines in a row become one empty line
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
