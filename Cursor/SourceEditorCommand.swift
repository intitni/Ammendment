//
//  SourceEditorCommand.swift
//  Cursor
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

class MoveCursor: NSObject, XCSourceEditorCommand {
    
    enum E: Error {
        case noSelectionFound
    }
    
    enum CommandType: String, CaseIterable {
        case moveUp = "moveUp"
        case moveDown = "moveDown"
        
        var lineAddition: Int {
            switch self {
            case .moveUp: return 5.up
            case .moveDown: return 5.down
            }
        }
        
        var identifier: String {
            return rawValue
        }
        
        var name: String {
            switch self {
            case .moveUp: return "Move Cursors Up 5 Lines"
            case .moveDown: return "Move Cursors Down 5 Lines"
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let command = CommandType(rawValue: invocation.commandIdentifier) else { fatalError() }
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(E.noSelectionFound)
            return
        }
        
        let newSelections: [XCSourceTextRange] = selections.map { this in
            let line = this.start.line
            let column = this.start.column
            return {
                let it = XCSourceTextRange()
                let position = XCSourceTextPosition(line: line + command.lineAddition, column: column)
                it.start = position
                it.end = position
                return it
            }()
        }
        
        invocation.buffer.selections.setArray(newSelections)
        
        completionHandler(nil)
    }
    
}

fileprivate extension Int {
    var up: Int { return -self }
    var down: Int { return self }
}
