import Foundation
import XcodeKit

/// Move cursors up or down by 5 lines
class MoveCursor: NSObject, XCSourceEditorCommand {
    enum Command: String, CaseIterable, CommandType {
        case moveUp = "moveCursorUp"
        case moveDown = "moveCursorDown"
        
        var commandClassName: String { return MoveCursor.className() }
        
        fileprivate var lineAddition: Int {
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
        guard let command = Command(rawValue: invocation.commandIdentifier.privateIdentifier) else { fatalError() }
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
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

/// Add a cursor above or below the current selections
class AddCursor: NSObject, XCSourceEditorCommand {
    enum Command: String, CaseIterable, CommandType {
        case above = "addCursorAbove"
        case below = "addCursorBelow"
        
        var commandClassName: String { return AddCursor.className() }
        
        var identifier: String {
            return rawValue
        }
        
        var name: String {
            switch self {
            case .above: return "Add Cursor Above"
            case .below: return "Add Cursor Below"
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let command = Command(rawValue: invocation.commandIdentifier.privateIdentifier) else { fatalError() }
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange],
              let first = selections.first,
              let last = selections.last
        else {
            completionHandler(nil)
            return
        }
        
        switch command {
        case .above:
            let line = first.start.line
            guard line > 0 else {
                // already at top, no upper line for new cursor
                completionHandler(nil)
                return
            }
            let column = first.start.column
            let newSelection: XCSourceTextRange = {
                let it = XCSourceTextRange()
                var pos = XCSourceTextPosition()
                pos.line = line - 1
                pos.column = column
                it.start = pos
                it.end = pos
                return it
            }()
            invocation.buffer.selections.setArray([newSelection] + selections)
        case .below:
            let line = last.end.line
            guard line < invocation.buffer.lines.count - 1 else {
                // already at bottom, no lower line for new cursor
                completionHandler(nil)
                return
            }
            let column = last.start.column
            let newSelection: XCSourceTextRange = {
                let it = XCSourceTextRange()
                var pos = XCSourceTextPosition()
                pos.line = line + 1
                pos.column = column
                it.start = pos
                it.end = pos
                return it
            }()
            invocation.buffer.selections.setArray(selections + [newSelection])
        }
        
        completionHandler(nil)
    }
}

fileprivate extension Int {
    var up: Int { return -self }
    var down: Int { return self }
}
