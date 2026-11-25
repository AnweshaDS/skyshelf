//
//  NoteEditorView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

// Sheet for writing a note on one favorite picture.
// @Binding: this screen edits the text that belongs to ShelfView.
struct NoteEditorView: View {

    @Environment(\.dismiss) private var dismiss   // closes the sheet

    let title: String
    @Binding var note: String
    var onSave: () -> Void
    var onDelete: () -> Void

    // true when the note box has the keyboard
    @FocusState private var isEditing: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                Text(title)
                    .font(.headline)
                    .lineLimit(2)

                Text("Your note")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // The note box: a TextField that can grow up to 8 lines
                TextField("Type your note here", text: $note, axis: .vertical)
                    .lineLimit(5...8)
                    .focused($isEditing)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
                    .onTapGesture {
                        isEditing = true
                    }

                // Save
                Button {
                    onSave()
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Delete note (only when there is something to delete)
                Button(role: .destructive) {
                    note = ""
                    onDelete()
                    dismiss()
                } label: {
                    Text("Delete note")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(note.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel closes without saving
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Done hides the keyboard
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isEditing = false
                    }
                }
            }
            // Open the keyboard shortly after the sheet appears
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isEditing = true
                }
            }
        }
    }
}
