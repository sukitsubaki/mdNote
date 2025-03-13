import Foundation
import SwiftUI

// Class to manage notes with persistence
class NoteStore: ObservableObject {
    // Published property to trigger UI updates
    @Published var notes: [Note] = []
    @Published var selectedNoteID: UUID?
    
    // UserDefaults key for storage
    private let notesKey = "mdnotes.stored.notes"
    
    // Add a new note
    func addNote() {
        let newNote = Note(title: "Untitled Note", content: "")
        notes.insert(newNote, at: 0)
        selectedNoteID = newNote.id
        saveNotes()
    }
    
    // Update an existing note
    func updateNote(id: UUID, title: String, content: String) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].update(title: title, content: content)
            saveNotes()
        }
    }
    
    // Delete a note
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        if notes.isEmpty {
            selectedNoteID = nil
        } else if selectedNoteID == nil {
            selectedNoteID = notes.first?.id
        }
        saveNotes()
    }
    
    // Delete a specific note by ID
    func deleteNote(id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes.remove(at: index)
            if selectedNoteID == id {
                selectedNoteID = notes.first?.id
            }
            saveNotes()
        }
    }
    
    // Get a note by ID
    func getNote(id: UUID) -> Note? {
        return notes.first(where: { $0.id == id })
    }
    
    // Select a note
    func selectNote(id: UUID) {
        selectedNoteID = id
    }
    
    // Save notes to UserDefaults
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
        } catch {
            print("Error saving notes: \(error)")
        }
    }
    
    // Load notes from UserDefaults
    func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: notesKey) else {
            // Create a sample note if no saved notes exist
            if notes.isEmpty {
                let sampleNote = Note(
                    title: "Welcome to mdNote!",
                    content: """
                    # Welcome to mdNote
                    
                    This is a simple markdown editor created by [Suki Tsubaki](https://github.com/sukitsubaki).
                    
                    ## Features
                    
                    - **Clean interface**: Focus on your writing
                    - **Markdown support**: Write in markdown and see the preview
                    - **Automatic saving**: Your notes are saved automatically
                    
                    ## Markdown Basics
                    
                    - *Italic* text with `*asterisks*`
                    - **Bold** text with `**double asterisks**`
                    - Lists start with `- ` or `1. `
                    - [Links](https://example.com) use `[text](url)`
                    - Code uses backticks: `code`
                    
                    Enjoy writing!
                    """
                )
                notes = [sampleNote]
                selectedNoteID = sampleNote.id
                saveNotes()
            }
            return
        }
        
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
            if !notes.isEmpty && selectedNoteID == nil {
                selectedNoteID = notes.first?.id
            }
        } catch {
            print("Error loading notes: \(error)")
            notes = []
        }
    }
    
    // Export note as text
    func exportNote(id: UUID) -> String? {
        return getNote(id: id)?.content
    }
}
