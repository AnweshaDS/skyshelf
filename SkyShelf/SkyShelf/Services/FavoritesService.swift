//
//  FavoritesService.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// All Firestore work for favorites.
// Path: users/{uid}/favorites/{date}
class FavoritesService: ObservableObject {

    @Published var favorites: [FavoriteItem] = []   // filled by the listener
    @Published var isLoaded = false                 // true after the first snapshot
    @Published var errorMessage = ""

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // The current user's "favorites" collection (nil if nobody is logged in)
    private func collection() -> CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("favorites")
    }

    // MARK: - Real-time list

    // Called from ShelfView.onAppear
    func startListening() {
        stopListening()
        guard let col = collection() else { return }
        errorMessage = ""

        listener = col.order(by: "savedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoaded = true
                        return
                    }
                    let docs = snapshot?.documents ?? []
                    self?.favorites = docs.map { FavoriteItem(document: $0) }
                    self?.isLoaded = true
                }
            }
    }

    // Called from ShelfView.onDisappear
    func stopListening() {
        listener?.remove()
        listener = nil
        favorites = []
        isLoaded = false
    }

    // MARK: - One-time check

    // Is this picture already saved? (used by the heart button)
    func checkSaved(date: String, completion: @escaping (Bool) -> Void) {
        guard let col = collection() else {
            completion(false)
            return
        }
        col.document(date).getDocument { snapshot, _ in
            DispatchQueue.main.async {
                completion(snapshot?.exists ?? false)
            }
        }
    }

    // MARK: - CRUD

    // ADD: the document ID is the date, so the same day can never be saved twice
    func add(item: APODItem, completion: @escaping (Bool) -> Void) {
        guard let col = collection() else {
            completion(false)
            return
        }
        let data: [String: Any] = [
            "title": item.title,
            "imageURL": item.displayImageURL?.absoluteString ?? "",
            "explanation": item.explanation,
            "mediaType": item.mediaType,
            "note": "",
            "savedAt": FieldValue.serverTimestamp()
        ]
        col.document(item.date).setData(data) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }

    // REMOVE
    func remove(date: String, completion: ((Bool) -> Void)? = nil) {
        guard let col = collection() else {
            completion?(false)
            return
        }
        col.document(date).delete { error in
            DispatchQueue.main.async {
                completion?(error == nil)
            }
        }
    }

    // ADD / EDIT / DELETE a note: an empty text means "no note"
    func updateNote(date: String, note: String, completion: ((Bool) -> Void)? = nil) {
        guard let col = collection() else {
            completion?(false)
            return
        }
        col.document(date).updateData(["note": note]) { error in
            DispatchQueue.main.async {
                completion?(error == nil)
            }
        }
    }
}
