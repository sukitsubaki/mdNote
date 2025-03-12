import SwiftUI

struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var newNoteContent: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("New Note", text: $newNoteContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        addNewNote()
                    }

                List(notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.content)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                .navigationTitle("mdNote")
            }
            .padding()
        }
    }

    func addNewNote() {
        let title = "Note \(notes.count + 1)"
        let note = Note(id: UUID(), title: title, content: newNoteContent)
        notes.append(note)
        newNoteContent = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
