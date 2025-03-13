import SwiftUI

@main
struct mdNoteApp: App {
    @StateObject private var noteStore = NoteStore()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(noteStore)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .onAppear {
                    // Load saved notes when app launches
                    noteStore.loadNotes()
                }
        }
    }
}
