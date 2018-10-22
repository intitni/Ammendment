import Foundation
import XcodeKit

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
            
            let jointLine = join(lines: lines[firstLineIndex...endLineIndex])
            invocation.buffer.lines.removeObjects(at: .init(integersIn: firstLineIndex+1 ... endLineIndex))
            invocation.buffer.lines[firstLineIndex] = jointLine
        }
        
        completionHandler(nil)
    }
    
    private func join(lines: ArraySlice<String>) -> String {
        guard lines.count > 1 else { return lines.first ?? "" }
        
        let removeEndOfLine = { (s: String) -> String in
             return s.trimmingCharacters(in: .newlines)
        }
        let trimWhiteSpacesAndNewLines = { (s: String) -> String in
            return s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let firstLine = [lines[lines.startIndex]].map(removeEndOfLine)
        let otherSelectedLines = lines[(lines.startIndex + 1)...].map(trimWhiteSpacesAndNewLines)
        let newLines = firstLine + otherSelectedLines
        return newLines.joined(separator: " ")
    }
}

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
    
    enum Number {
        case floatingPoint(Double)
        case integer(Int)
        
        func increased() -> Number {
            switch self {
            case let .integer(val): return .integer(val + 1)
            case let .floatingPoint(val): return .floatingPoint(val + 0.1)
            }
        }
        
        func decreased() -> Number {
            switch self {
            case let .integer(val): return .integer(val - 1)
            case let .floatingPoint(val): return .floatingPoint(val - 0.1)
            }
        }
        
        var text: String {
            switch self {
            case let .integer(val): return "\(val)"
            case let .floatingPoint(val):
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 1
                formatter.minimumIntegerDigits = 1
                return "\(formatter.string(from: .init(value: val)) ?? "")"
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        guard let command = Command(rawValue: invocation.commandIdentifier.privateIdentifier) else { fatalError() }
        guard let selections = invocation.buffer.selections as? [XCSourceTextRange] else {
            completionHandler(nil)
            return
        }
        
        for selection in selections {
            guard selection.start.line == selection.end.line else { continue }
            let lineIndex = selection.start.line
            let start = selection.start.column
            let end = selection.end.column
            let line = invocation.buffer.lines[lineIndex] as! String
            
            guard let (newLine, newEnd) = updating(line: line, with: command, from: start, to: end) else { continue }
            selection.end = .init(line: lineIndex, column: newEnd)
            invocation.buffer.lines.replaceObject(at: lineIndex, with: newLine)
        }
        
        completionHandler(nil)
    }
    
    private func number(inLine line: String, from start: Int, to end: Int) -> Number? {
        let text = selectedTrimmedText(inLine: line, from: start, to: end)
        guard let double = Double(text) else { return nil }
        if text.contains(".") { return Number.floatingPoint(double) }
        return .integer(Int(double))
    }
    
    private func selectedTrimmedText(inLine line: String, from start: Int, to end: Int) -> String {
        assert(end >= start)
        let index = indexFactory(in: line)
        return String(line[index(start)..<index(end)]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func updating(line: String, with command: Command, from start: Int, to end: Int) -> (newLine: String, newEnd: Int)? {
        guard let num = number(inLine: line, from: start, to: end) else { return nil }
        let selectedText = selectedTrimmedText(inLine: line, from: start, to: end)
        
        let updatedNum: Number
        switch command {
        case .increase: updatedNum = num.increased()
        case .decrease: updatedNum = num.decreased()
        }
        let index = indexFactory(in: line)
        let newText = updatedNum.text
        return (line.replacingOccurrences(of: selectedText,
                                          with: newText,
                                          options: [],
                                          range: index(start)..<index(end)),
                end + (newText.count - selectedText.count))
    }
}
