import Foundation
import XcodeKit

func indexFactory(in line: String) -> (_ offset: Int) -> String.Index {
    return { (offset: Int) -> String.Index in return line.index(line.startIndex, offsetBy: offset) }
}

extension XCSourceTextPosition {
    init(line: Int, column: Int) {
        self.init()
        self.line = line
        self.column = column
    }
}

extension XCSourceTextRange {
    convenience init(start: XCSourceTextPosition, end: XCSourceTextPosition) {
        self.init()
        self.start = start
        self.end = end
    }
}

enum Helper {
    struct WordOccurrence {
        let word: String
        let range: XCSourceTextRange
    }
    
    static func findWordAtCursor(
        with buffer: XCSourceTextBuffer,
        at position: XCSourceTextPosition
    ) -> WordOccurrence? {
        let lines = buffer.lines
        let targetLine = (lines[position.line] as! String).map { $0 }
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
    
    static func selectedText(in buffer: XCSourceTextBuffer, in range: XCSourceTextRange) -> String {
        if range.start.line == range.end.line {
            return String((buffer.lines[range.start.line] as! String).map({$0})[range.start.column..<range.end.column])
        }
        return String((buffer.lines[range.start.line] as! String).map({$0})[range.start.column...])
            + { var string = ""
                for i in range.start.line + 1 ..< range.end.line {
                    let s = buffer.lines[i] as! String
                    string += s
                }
                return string
            }()
            + String((buffer.lines[range.end.line] as! String).map({$0})[...range.end.column])
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
