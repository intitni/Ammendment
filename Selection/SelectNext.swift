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
        assert(end.line == start.line)
        
        let lastLine = lines[end.line]
        
        let lineStartIndex = lastLine.indexFactory(start.column)
        let lineEndIndex = lastLine.indexFactory(end.column)
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
        assert(end.line > start.line)
        
        let lineHeight = end.line - start.line
        for startLineIndex in end.line ..< lines.endIndex - lineHeight {
            let endLineIndex = startLineIndex + lineHeight
            
            let match = matchNextSelection(lines[startLineIndex...endLineIndex],
                                            toPreviousLines: lines[start.line...end.line],
                                            startColumn: start.column,
                                            endColumn: end.column)
            guard match else { continue }
            let firstLineLength = lines[startLineIndex].count
            let selectedFirstLineTextLength = lines[start.line].count - start.column
            return TextRange(start: .init(line: startLineIndex, column: firstLineLength - selectedFirstLineTextLength),
                             end: .init(line: endLineIndex, column: end.column))
        }
        
        return nil
    }
    
    private func matchNextSelection(
        _ next: ArraySlice<String>,
        toPreviousLines previous: ArraySlice<String>,
        startColumn: Int,
        endColumn: Int) -> Bool {
        guard next.count == previous.count,
            let previousFirstLine = previous.first,
            let previousLastLine = previous.last,
            let nextFirstLine = next.first,
            let nextLastLine = next.last,
            startColumn > 0, endColumn <= previousFirstLine.count
            else { return false }
        
        let previousFirstLineSelectedText = previousFirstLine[previousFirstLine.indexFactory(startColumn)...]
        let previousLastLineSelectedText = previousLastLine[..<previousLastLine.indexFactory(endColumn)]
        
        guard nextFirstLine.hasSuffix(previousFirstLineSelectedText) else { return false }
        guard nextLastLine.hasPrefix(previousLastLineSelectedText) else { return false }
        
        for i in next.startIndex + 1 ..< next.endIndex - 1 {
            if next[i] != previous[i] { return false }
        }
        
        return true
    }
}
