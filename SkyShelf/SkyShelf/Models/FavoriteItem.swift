//
//  FavoriteItem.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation
import FirebaseFirestore

// One saved picture on the user's shelf.
// Fields are read from the Firestore dictionary by hand (no Codable),
// so every line is easy to explain.
struct FavoriteItem: Identifiable {
    let id: String            // the date, also the Firestore document ID
    let title: String
    let imageURL: String      // may be empty for videos without a thumbnail
    let explanation: String
    let mediaType: String
    let note: String          // empty text means "no note"
    let savedAt: Date

    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        title = data["title"] as? String ?? ""
        imageURL = data["imageURL"] as? String ?? ""
        explanation = data["explanation"] as? String ?? ""
        mediaType = data["mediaType"] as? String ?? "image"
        note = data["note"] as? String ?? ""
        // A Firestore timestamp becomes a Swift Date
        savedAt = (data["savedAt"] as? Timestamp)?.dateValue() ?? Date()
    }
}
