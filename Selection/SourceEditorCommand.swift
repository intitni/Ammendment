//
//  SourceEditorCommand.swift
//  Selection
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

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
                var startCol = 0
                var index = lineContent.startIndex
                var foundCharacter = false
                while index < lineContent.endIndex {
                    if lineContent[index].isTabOrSpcase { startCol += 1 }
                    else { foundCharacter = true; break }
                    index = lineContent.index(after: index)
                }
                
                if !foundCharacter { continue }
                
                let endCol = lineContent.count - 1
                let lineSelection: XCSourceTextRange = {
                    let it = XCSourceTextRange()
                    it.start = XCSourceTextPosition(line: currentLine, column: startCol)
                    it.end = XCSourceTextPosition(line: currentLine, column: endCol)
                    return it
                }()
                splitSelections.append(lineSelection)
            }
            
            return splitSelections
        }
        
        let newSelections = newSelectionsGroup.flatMap { $0 }
        
        invocation.buffer.selections.setArray(newSelections)
        
        completionHandler(nil)
    }
}

class SelectWord: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return SelectWord.className() }
    var identifier: String { return "SelectWords" }
    var name: String { return "Select Next Word" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        completionHandler(nil)
    }
    
}

extension Character {
    static var tab: Character { return "\t" }
    static var space: Character { return " " }
    static var end: Character { return "\n" }
    
    var isTabOrSpcase: Bool { return self == Character.tab || self == Character.space }
    var isEndOfLine: Bool { return self == Character.end }
}
