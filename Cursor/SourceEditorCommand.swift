//
//  SourceEditorCommand.swift
//  Cursor
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    enum E: Error {
        case noSelectionFound
    }
    
    enum CommandType: String, CaseIterable {
        case moveUp = "moveUp"
        case moveDown = "moveDown"
        
        var lineAddition: Int {
            switch self {
            case .moveUp: return -5
            case .moveDown: return 5
            }
        }
        
        var identifier: String {
            return rawValue
        }
        
        var name: String {
            switch self {
            case .moveUp: return "Move Cursor Up 5 Lines"
            case .moveDown: return "Move Cursor Down 5 Lines"
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let command = CommandType(rawValue: invocation.commandIdentifier) else { fatalError() }
        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(E.noSelectionFound)
            return
        }
        
        let line = firstSelection.start.line
        let column = firstSelection.start.column
        let newSelection: XCSourceTextRange = {
            let it = XCSourceTextRange()
            let position = XCSourceTextPosition(line: line + command.lineAddition, column: column)
            it.start = position
            it.end = position
            return it
        }()
        
        invocation.buffer.selections.setArray([newSelection])
        
        completionHandler(nil)
    }
    
}
