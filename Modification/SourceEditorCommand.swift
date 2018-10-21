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
        
        for selection in selections.reversed() {
            let firstLineIndex = selection.start.line
            let endLineIndex = selection.end.line
            
            let lines = [(invocation.buffer.lines[firstLineIndex] as! String).replacingOccurrences(of: "\(Character.end)", with: "")]
                + (invocation.buffer.lines.objects(at: .init(firstLineIndex+1 ... endLineIndex)) as! [String]).map { return $0
                    .replacingOccurrences(of: "\(Character.end)", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
            let jointLine = lines.joined(separator: " ")
            invocation.buffer.lines.removeObjects(at: .init(integersIn: firstLineIndex+1 ... endLineIndex))
            invocation.buffer.lines[firstLineIndex] = jointLine
        }
        
        completionHandler(nil)
    }
    
}
