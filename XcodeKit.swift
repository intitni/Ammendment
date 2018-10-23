import Foundation
import XcodeKit

extension XCSourceTextPosition {
    init(line: Int, column: Int) {
        self.init()
        self.line = line
        self.column = column
    }
    
    init(position: Position) {
        self.init(line: position.line, column: position.column)
    }
    
    var position: Position {
        return .init(line: line, column: column)
    }
}

extension XCSourceTextRange {
    convenience init(start: XCSourceTextPosition, end: XCSourceTextPosition) {
        self.init()
        self.start = start
        self.end = end
    }
    
    convenience init(range: TextRange) {
        self.init(start: XCSourceTextPosition(position: range.start),
                  end: XCSourceTextPosition(position: range.end))
    }
    
    var textRange: TextRange {
        return .init(start: start.position, end: end.position)
    }
}
