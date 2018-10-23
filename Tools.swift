import Foundation

func indexFactory(in line: String) -> (_ offset: Int) -> String.Index {
    return { (offset: Int) -> String.Index in return line.index(line.startIndex, offsetBy: offset) }
}

struct Position {
    var line: Int
    var column: Int
}

struct TextRange {
    var start: Position
    var end: Position
}

enum Helper {
    struct WordOccurrence {
        let word: String
        let range: TextRange
    }
    
    static func findWordAtCursor(
        with lines: [String],
        at position: Position
    ) -> WordOccurrence? {
        let targetLine = lines[position.line].map { $0 }
        let currentChar = targetLine[position.column]
        guard currentChar.isCharacter else { return nil }
        
        func traceEndIndex(from line: [Character], startFrom: Int) -> Int {
            guard startFrom < line.endIndex else { return startFrom }
            var index = startFrom + 1
            while index < line.endIndex {
                if !line[index].isCharacter { return index }
                index += 1
            }
            return index
        }
        
        func traceStartIndex(from line: [Character], startFrom: Int) -> Int {
            guard startFrom > 0 else { return startFrom }
            var index = startFrom - 1
            while index > 0 {
                if !line[index].isCharacter { return index + 1 }
                index -= 1
            }
            return index
        }
        
        let startIndex = traceStartIndex(from: targetLine, startFrom: position.column)
        let endIndex = traceEndIndex(from: targetLine, startFrom: position.column)
        
        return WordOccurrence(
            word: String(targetLine[startIndex...endIndex]),
            range: .init(start: .init(line: position.line, column: startIndex),
                         end: .init(line: position.line, column: endIndex)))
    }
    
    static func selectedText(in lines: [String], in range: TextRange) -> String {
        if range.start.line == range.end.line {
            return String(lines[range.start.line].map({$0})[range.start.column..<range.end.column])
        }
        return String(lines[range.start.line].map({$0})[range.start.column...])
            + { var string = ""
                for i in range.start.line + 1 ..< range.end.line {
                    string += lines[i]
                }
                return string
            }()
            + String(lines[range.end.line].map({$0})[...range.end.column])
    }
}

extension Character {
    static var tab: Character { return "\t" }
    static var end: Character { return "\n" }
    private var set: CharacterSet { return CharacterSet(charactersIn: "\(self)") }
    
    var isTabOrSpcase: Bool { return self == Character.tab || CharacterSet.whitespaces.isSuperset(of: set) }
    var isEndOfLine: Bool { return CharacterSet.newlines.isSuperset(of: set) }
    var isCharacter: Bool {
        return CharacterSet.decimalDigits
            .union(CharacterSet.letters)
            .union(.init(charactersIn: "_-"))
            .isSuperset(of: set) }
}
