import SwiftUI

struct ContentView: View {
    @EnvironmentObject var noteStore: NoteStore
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            // Sidebar with note list
            NoteListView()
                .frame(minWidth: 200)
            
            // Main content area
            if let selectedID = noteStore.selectedNoteID,
               let selectedNote = noteStore.getNote(id: selectedID) {
                NoteEditorView(note: selectedNote)
            } else {
                // Empty state when no note is selected
                EmptyNoteView()
            }
        }
        .navigationTitle("mdNote")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    noteStore.addNote()
                }) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max")
                }
                .toggleStyle(.button)
            }
        }
    }
}

struct EmptyNoteView: View {
    @EnvironmentObject var noteStore: NoteStore
    
    var body: some View {
        VStack {
            Image(systemName: "note.text")
                .font(.system(size: 56))
                .foregroundColor(.gray)
            
            Text("No Note Selected")
                .font(.title2)
                .padding()
            
            Text("Select a note from the sidebar or create a new one")
                .foregroundColor(.gray)
            
            Button(action: {
                noteStore.addNote()
            }) {
                Label("Create New Note", systemImage: "plus")
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let noteStore = NoteStore()
        noteStore.notes = [
            Note(title: "Sample Note", content: "# Sample Content\n\nThis is a sample note.")
        ]
        
        return ContentView()
            .environmentObject(noteStore)
    }
}
