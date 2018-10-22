//
//  SourceEditorCommand.swift
//  Selection
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

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
    
    enum SelectType {
        case selectWords
        case selectNext
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        func getSelectType() -> SelectType {
            var hasEmptySelection = false
            var hasDifferentSelections = false
            var previousText: String?
            
            for selection in selections {
                let text = Helper.selectedText(in: invocation.buffer, in: selection)
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
        
        func selectWordsAtCursor() {
            let newSelections: [XCSourceTextRange] = selections
                .map { range in
                    let result = Helper.findWordAtCursor(with: invocation.buffer, at: range.start)
                    return result?.range
                }
                .compactMap { $0 }
            invocation.buffer.selections.removeAllObjects()
            invocation.buffer.selections.addObjects(from: newSelections)
        }
        
        func selectNextOccurrenceOfSelection() {
            guard let lastSelection = selections.last else { completionHandler(nil); return }
            let start = lastSelection.start
            let end = lastSelection.end
            let lines = invocation.buffer.lines as! [String]
            
            if end.line > start.line {
                let lastLineLeftover = String(lines[end.line].map({$0})[end.column...])
                let leftover = [lastLineLeftover] + lines[(end.line + 1)...]
                
                for l in 0..<leftover.endIndex - (end.line - start.line) {
                    // TODO: multiline select next
                }
            } else {
                let lastLine = lines[end.line]
                let lineStartIndex = lastLine.index(lastLine.startIndex, offsetBy: start.column)
                let lineEndIndex = lastLine.index(lastLine.startIndex, offsetBy: end.column)
                let selectedWord = String(lastLine[lineStartIndex..<lineEndIndex])
                let lastLineLeftover = lastLine[lineEndIndex...]
                
                if let range = lastLineLeftover.range(of: selectedWord) {
                    let nsrange = NSRange(range, in: lastLine)
                    let xcrange = XCSourceTextRange(start: .init(line: start.line, column: nsrange.lowerBound),
                                                    end: .init(line: start.line, column: nsrange.upperBound))
                    invocation.buffer.selections.add(xcrange)
                    return
                }
                
                for index in start.line + 1 ..< lines.endIndex {
                    let currentLine = lines[index]
                    if let range = currentLine.range(of: selectedWord) {
                        let nsrange = NSRange(range, in: currentLine)
                        let xcrange = XCSourceTextRange(start: .init(line: index, column: nsrange.lowerBound),
                                                        end: .init(line: index, column: nsrange.upperBound))
                        invocation.buffer.selections.add(xcrange)
                        return
                    }
                }
            }
        }
        
        switch getSelectType() {
        case .selectWords: selectWordsAtCursor()
        case .selectNext: selectNextOccurrenceOfSelection()
        }
        
        completionHandler(nil)
    }
}
