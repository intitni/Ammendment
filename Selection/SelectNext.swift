import Foundation

class SelectNextHelper {
    enum SelectType {
        case selectWords
        case selectNext
    }
    
    func getSelectType(lines: [String], selections: [TextRange]) -> SelectType {
        var hasEmptySelection = false
        var hasDifferentSelections = false
        var previousText: String?
        
        for selection in selections {
            let text = Helper.selectedText(in: lines, in: selection)
            if let previous = previousText, previous != text {
                hasDifferentSelections = true
            }
            previousText = text
            
            if selection.start.line == selection.end.line && selection.start.column == selection.end.column {
                hasEmptySelection = true
            }
            
            if hasEmptySelection && hasDifferentSelections { break }
        }
        
        if hasEmptySelection { return .selectWords }
        if hasDifferentSelections { return .selectWords }
        return .selectNext
    }
    
    func getSelectionsCoveringWordsUnderCursors(lines: [String], selections: [TextRange]) -> [TextRange] {
        let newSelections: [TextRange] = selections
            .map { range in
                let result = Helper.findWordAtCursor(with: lines, at: range.start)
                return result?.range
            }
            .compactMap { $0 }
        return newSelections
    }
    
    func getNextOccurrenceOfSingleLine(inLines lines: [String], lastSelection: TextRange) -> TextRange? {
        let start = lastSelection.start
        let end = lastSelection.end
        let lastLine = lines[end.line]
        let lineStartIndex = lastLine.index(lastLine.startIndex, offsetBy: start.column)
        let lineEndIndex = lastLine.index(lastLine.startIndex, offsetBy: end.column)
        let selectedWord = String(lastLine[lineStartIndex..<lineEndIndex])
        let lastLineLeftover = lastLine[lineEndIndex...]
        
        if let range = lastLineLeftover.range(of: selectedWord) {
            let nsrange = NSRange(range, in: lastLine)
            let result = TextRange(start: .init(line: start.line, column: nsrange.lowerBound),
                                   end: .init(line: start.line, column: nsrange.upperBound))
            return result
        }
        
        for index in start.line + 1 ..< lines.endIndex {
            let currentLine = lines[index]
            if let range = currentLine.range(of: selectedWord) {
                let nsrange = NSRange(range, in: currentLine)
                let result = TextRange(start: .init(line: index, column: nsrange.lowerBound),
                                       end: .init(line: index, column: nsrange.upperBound))
                return result
            }
        }
        
        return nil
    }
    
    func getNextOccurrenceOfMultiLine(inLines lines: [String], lastSelection: TextRange) -> TextRange? {
        let start = lastSelection.start
        let end = lastSelection.end
        let lastLineLeftover = String(lines[end.line].map({$0})[end.column...])
        let leftover = [lastLineLeftover] + lines[(end.line + 1)...]
        
        for l in 0..<leftover.endIndex - (end.line - start.line) {
            // TODO: multiline select next
        }
        return nil
    }
}
