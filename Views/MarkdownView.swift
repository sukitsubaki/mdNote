import SwiftUI

// A view that renders Markdown content
struct MarkdownView: View {
    let text: String
    
    var body: some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            // Use the built-in Markdown rendering on iOS 15+/macOS 12+
            Text(parseMarkdown())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            // Fallback for earlier versions
            LegacyMarkdownView(text: text)
        }
    }
    
    // Parse markdown using AttributedString for iOS 15+/macOS 12+
    @available(iOS 15.0, macOS 12.0, *)
    private func parseMarkdown() -> AttributedString {
        do {
            return try AttributedString(markdown: text)
        } catch {
            print("Error parsing markdown: \(error)")
            return AttributedString(text)
        }
    }
}

// A basic markdown renderer for older OS versions
struct LegacyMarkdownView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(parseLines(), id: \.self) { line in
                parseLineView(line)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Split text into lines
    private func parseLines() -> [String] {
        return text.components(separatedBy: "\n")
    }
    
    // Render a single line based on its content
    private func parseLineView(_ line: String) -> some View {
        // Handle headings
        if line.hasPrefix("# ") {
            return AnyView(Text(line.dropFirst(2))
                            .font(.largeTitle)
                            .fontWeight(.bold))
        } else if line.hasPrefix("## ") {
            return AnyView(Text(line.dropFirst(3))
                            .font(.title)
                            .fontWeight(.bold))
        } else if line.hasPrefix("### ") {
            return AnyView(Text(line.dropFirst(4))
                            .font(.title2)
                            .fontWeight(.bold))
        }
        // Handle bullet lists
        else if line.hasPrefix("- ") {
            return AnyView(HStack(alignment: .top) {
                Text("•")
                Text(line.dropFirst(2))
            })
        }
        // Handle numbered lists (basic)
        else if line.matches(pattern: "^\\d+\\. ") {
            let components = line.components(separatedBy: ". ")
            if components.count >= 2 {
                return AnyView(HStack(alignment: .top) {
                    Text("\(components[0]).")
                    Text(components[1...].joined(separator: ". "))
                })
            }
        }
        // Handle blockquotes
        else if line.hasPrefix("> ") {
            return AnyView(HStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 4)
                Text(line.dropFirst(2))
                    .italic()
                    .padding(.leading, 8)
            })
        }
        // Handle code blocks (single line)
        else if line.hasPrefix("    ") || line.hasPrefix("\t") {
            return AnyView(Text(line.hasPrefix("    ") ? String(line.dropFirst(4)) : String(line.dropFirst(1)))
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4))
        }
        
        // Default: regular paragraph text with basic styling
        return AnyView(Text(parseInlineStyles(line)))
    }
    
    // Basic parsing for inline styles (bold, italic)
    private func parseInlineStyles(_ text: String) -> Text {
        var result = Text("")
        
        // Very basic parser for bold and italic
        // A more robust parser would use regex or a dedicated markdown parser
        let parts = text.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            if i % 2 == 1 {
                // Bold text (between ** **)
                result = result + Text(part).bold()
            } else {
                // Handle italic within non-bold text
                let italicParts = part.components(separatedBy: "*")
                for (j, italicPart) in italicParts.enumerated() {
                    if j % 2 == 1 {
                        // Italic text (between * *)
                        result = result + Text(italicPart).italic()
                    } else {
                        // Plain text
                        result = result + Text(italicPart)
                    }
                }
            }
        }
        
        return result
    }
}

// Extension to help with regex matching
extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            MarkdownView(text: """
            # Heading 1
            ## Heading 2
            ### Heading 3
            
            This is a paragraph with **bold** and *italic* text.
            
            - Bullet point 1
            - Bullet point 2
            
            1. Numbered item 1
            2. Numbered item 2
            
            > This is a blockquote
            
                This is a code block
            """)
            .padding()
        }
    }
}
