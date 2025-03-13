import Foundation

struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    // Computed property for preview text (first 100 characters)
    var preview: String {
        if content.isEmpty {
            return "Empty note"
        }
        
        let previewLength = min(content.count, 100)
        let endIndex = content.index(content.startIndex, offsetBy: previewLength)
        return String(content[..<endIndex]) + (content.count > 100 ? "..." : "")
    }
    
    // Init with default values
    init(id: UUID = UUID(), title: String = "", content: String = "") {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Update the note content and modification date
    mutating func update(title: String, content: String) {
        self.title = title
        self.content = content
        self.updatedAt = Date()
    }
    
    // Helper to get formatted creation date
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }
    
    // For Equatable conformance
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}
