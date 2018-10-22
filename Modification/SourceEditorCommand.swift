//
//  SourceEditorCommand.swift
//  Modification
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

class JoinLines: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return JoinLines.className() }
    var identifier: String { return "JoinLines" }
    var name: String { return "Join Selected Lines" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        let lines = invocation.buffer.lines as! [String]
        
        for selection in selections.reversed() {
            let firstLineIndex = selection.start.line
            let endLineIndex = selection.end.line
            
            guard endLineIndex > firstLineIndex else { continue }
            
            let firstLine = lines[firstLineIndex]
                .replacingOccurrences(of: "\(Character.end)", with: "")
            let otherSelectedLines = lines[firstLineIndex+1 ... endLineIndex]
                .map { return $0
                    .replacingOccurrences(of: "\(Character.end)", with: "")
                    .trimmingCharacters(in: .whitespaces)
                }
            let newLines = [firstLine] + otherSelectedLines
            let jointLine = newLines.joined(separator: " ")
            invocation.buffer.lines.removeObjects(at: .init(integersIn: firstLineIndex+1 ... endLineIndex))
            invocation.buffer.lines[firstLineIndex] = jointLine
        }
        
        completionHandler(nil)
    }
    
}
