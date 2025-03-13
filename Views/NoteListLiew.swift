import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return noteStore.notes
        } else {
            return noteStore.notes.filter { note in
                note.title.lowercased().contains(searchText.lowercased()) ||
                note.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteListItemView(note: note)
                    .listRowBackground(
                        noteStore.selectedNoteID == note.id ? 
                            Color.accentColor.opacity(0.2) : 
                            Color.clear
                    )
                    .onTapGesture {
                        noteStore.selectNote(id: note.id)
                    }
            }
            .onDelete(perform: noteStore.deleteNote)
        }
        .listStyle(SidebarListStyle())
        .searchable(text: $searchText, prompt: "Search notes")
        .overlay {
            if noteStore.notes.isEmpty {
                VStack {
                    Text("No Notes")
                        .font(.headline)
                    Text("Create a new note to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        noteStore.addNote()
                    }) {
                        Label("New Note", systemImage: "plus")
                            .padding(8)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
            }
        }
    }
}

struct NoteListItemView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(note.preview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(note.formattedDate())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        let noteStore = NoteStore()
        noteStore.notes = [
            Note(title: "Sample Note 1", content: "Content for sample note 1"),
            Note(title: "Sample Note 2", content: "Content for sample note 2")
        ]
        
        return NoteListView()
            .environmentObject(noteStore)
            .frame(width: 250)
    }
}
