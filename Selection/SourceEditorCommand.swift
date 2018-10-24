import Foundation
import XcodeKit

/// Select lines where cursors in
class SelectLine: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return SelectLine.className() }
    var identifier: String { return "SelectLine" }
    var name: String { return "Select Current Lines" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        let newSelectionsGroup: [[XCSourceTextRange]] = selections.map { selection in
            let startLine = selection.start.line
            let endLine = selection.end.line
            var splitSelections: [XCSourceTextRange] = []
            
            for currentLine in startLine...endLine {
                let lineContent = invocation.buffer.lines[currentLine] as! String
                guard lineContent != String(Character.end) else { continue }
                var startCol = 0
                var index = lineContent.startIndex
                var foundCharacter = false
                while index < lineContent.endIndex {
                    if lineContent[index].isTabOrSpcase { startCol += 1 }
                    else if !lineContent[index].isEndOfLine { foundCharacter = true; break }
                    index = lineContent.index(after: index)
                }
                
                if !foundCharacter { continue }
                
                let endCol = lineContent.count - 1
                let lineSelection = XCSourceTextRange(start: .init(line: currentLine, column: startCol),
                                                      end: .init(line: currentLine, column: endCol))
                splitSelections.append(lineSelection)
            }
            
            return splitSelections
        }
        
        let newSelections = newSelectionsGroup.flatMap { $0 }
        
        invocation.buffer.selections.setArray(newSelections)
        
        completionHandler(nil)
    }
}

/// Select words where cusors in,
/// or select next word if all selections are the same and no new cursor was added
class SelectNext: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return SelectNext.className() }
    var identifier: String { return "SelectNext" }
    var name: String { return "Select Next" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        let buffer = invocation.buffer
        let lines = buffer.lines as! [String]
        
        let helper = SelectNextHelper()

        func selectWordsAtCursor() {
            let newSelections = helper.getSelectionsCoveringWordsUnderCursors(
                lines: lines,
                selections: selections.map({$0.textRange}))
                    .map(XCSourceTextRange.init(range:))
            
            invocation.buffer.selections.removeAllObjects()
            invocation.buffer.selections.addObjects(from: newSelections)
        }
        
        func selectNextOccurrenceOfSelection() {
            guard let lastSelection = selections.last else { completionHandler(nil); return }
            let lastRange = lastSelection.textRange
            let start = lastSelection.start
            let end = lastSelection.end
            let lines = invocation.buffer.lines as! [String]
            if end.line > start.line {
                guard let range = helper.getNextOccurrenceOfMultiLine(inLines: lines, lastSelection: lastRange)
                    else {return}
                invocation.buffer.selections.add(XCSourceTextRange(range: range))
            } else {
                guard let range = helper.getNextOccurrenceOfSingleLine(inLines: lines, lastSelection: lastRange)
                    else {return}
                invocation.buffer.selections.add(XCSourceTextRange(range: range))
            }
        }
        
        switch helper.getSelectType(lines: lines, selections: selections.map {$0.textRange}) {
        case .selectWords: selectWordsAtCursor()
        case .selectNext: selectNextOccurrenceOfSelection()
        }
        
        completionHandler(nil)
    }
}
