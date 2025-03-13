import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject var noteStore: NoteStore
    let note: Note
    
    @State private var title: String
    @State private var content: String
    @State private var isPreviewMode = false
    @State private var isExporting = false
    
    init(note: Note) {
        self.note = note
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Note title editor
            TextField("Title", text: $title)
                .font(.title2)
                .padding()
                .onChange(of: title) { newValue in
                    noteStore.updateNote(id: note.id, title: newValue, content: content)
                }
            
            Divider()
            
            // Toolbar for editor
            HStack {
                Button(action: {
                    isPreviewMode.toggle()
                }) {
                    Label(isPreviewMode ? "Edit" : "Preview", 
                          systemImage: isPreviewMode ? "pencil" : "eye")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("\(content.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    isExporting = true
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Content area - either editor or preview
            if isPreviewMode {
                ScrollView {
                    MarkdownView(text: content)
                        .padding()
                }
            } else {
                TextEditor(text: $content)
                    .font(.body.monospaced())
                    .padding(.horizontal)
                    .onChange(of: content) { newValue in
                        noteStore.updateNote(id: note.id, title: title, content: newValue)
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    noteStore.deleteNote(id: note.id)
                }) {
                    Label("Delete Note", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $isExporting) {
            ExportView(note: note)
        }
    }
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let note: Note
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Note Details")) {
                    LabeledContent("Title", value: note.title)
                    LabeledContent("Created", value: note.formattedDate())
                    LabeledContent("Size", value: "\(note.content.count) characters")
                }
                
                Section(header: Text("Export Options")) {
                    Button(action: {
                        copyToClipboard(note.content)
                        dismiss()
                    }) {
                        Label("Copy as Markdown", systemImage: "doc.on.clipboard")
                    }
                    
                    Button(action: {
                        // In a real app, this would save to a file
                        copyToClipboard(note.content)
                        dismiss()
                    }) {
                        Label("Save as Markdown File", systemImage: "arrow.down.doc")
                    }
                }
            }
            .navigationTitle("Export Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

struct NoteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNote = Note(
            title: "Sample Note",
            content: "# This is a heading\n\nThis is a paragraph with **bold** and *italic* text."
        )
        
        return NoteEditorView(note: sampleNote)
            .environmentObject(NoteStore())
    }
}
