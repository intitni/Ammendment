import Foundation

class JoinLineHelper {
    func join(lines: ArraySlice<String>) -> String {
        guard lines.count > 1 else { return lines.first ?? "" }
        
        let removeEndOfLine = { (s: String) -> String in
            return String(("0" + s).trimmingCharacters(in: .whitespacesAndNewlines).dropFirst())
        }
        let trimWhiteSpacesAndNewLines = { (s: String) -> String in
            return s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let firstLine = [lines[lines.startIndex]].map(removeEndOfLine)
        let otherSelectedLines = lines[(lines.startIndex + 1)...].map(trimWhiteSpacesAndNewLines)
        let newLines = firstLine + otherSelectedLines
        return newLines.joined(separator: " ") + String(Character.end)
    }
}
