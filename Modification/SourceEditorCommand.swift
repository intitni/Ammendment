import Foundation
import XcodeKit

/// Increase or decrease selected number
class IncreaseDecrease: NSObject, XCSourceEditorCommand {
    enum Command: String, CaseIterable, CommandType {
        case increase = "IncreaseNum"
        case decrease = "DecreaseNum"
        
        var commandClassName: String { return IncreaseDecrease.className() }
        var identifier: String { return rawValue }
        var name: String {
            switch self {
            case .increase: return "Increase Selected Number"
            case .decrease: return "Decrease Selected Number"
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        guard let command = Command(rawValue: invocation.commandIdentifier.privateIdentifier) else { fatalError() }
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        let helper = IncreaseDecreaseHelper()
        
        for selection in selections {
            guard selection.start.line == selection.end.line else { continue }
            let lineIndex = selection.start.line
            let start = selection.start.column
            let end = selection.end.column
            let line = invocation.buffer.lines[lineIndex] as! String
            
            guard let (newLine, newEnd) = helper.updating(line: line, toIncrease: command == .increase, from: start, to: end)
                else { continue }
            selection.end = .init(line: lineIndex, column: newEnd)
            invocation.buffer.lines.replaceObject(at: lineIndex, with: newLine)
        }
        
        completionHandler(nil)
    }
}

/// Join selected lines in same selections into 1 line
class JoinLines: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return JoinLines.className() }
    var identifier: String { return "JoinLines" }
    var name: String { return "Join Selected Lines" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        var lines: [String] { return invocation.buffer.lines as! [String] }
        
        for selection in selections.reversed() {
            let firstLineIndex = selection.start.line
            let endLineIndex = selection.end.line
            
            guard firstLineIndex < endLineIndex else { continue }
            
            let jointLine = JoinLineHelper().join(lines: lines[firstLineIndex...endLineIndex])
            invocation.buffer.lines.removeObjects(at: .init(integersIn: firstLineIndex+1 ... endLineIndex))
            invocation.buffer.lines[firstLineIndex] = jointLine
        }
        
        completionHandler(nil)
    }
}

// Remove auto generated comments at top
class RemoveCommnetAtTop: NSObject, XCSourceEditorCommand, CommandType {
    var commandClassName: String { return RemoveCommnetAtTop.className() }
    var identifier: String { return "RemoveCommnetAtTop" }
    var name: String { return "Remove Commnets At Top" }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        var lines: [String] { return invocation.buffer.lines as! [String] }
        
        let helper = RemoveCommentAtTopHelper()
        guard let lastLineToRemoveIndex = helper.findEndLineIndexOfTopComment(from: lines) else {
            completionHandler(nil)
            return
        }
        
        invocation.buffer.lines.removeObjects(in: .init(location: 0, length: lastLineToRemoveIndex))
        
        completionHandler(nil)
    }
}
