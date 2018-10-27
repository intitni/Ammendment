import Foundation

class RemoveCommentAtTopHelper {
    func findEndLineIndexOfTopComment(from lines: [String]) -> Int? {
        let index: Int = {
            var hitEmptyLine = false
            for lastIndex in -1..<lines.count {
                let i = lastIndex + 1
                let line = lines[i]
                if line.prefix(2) == "//" && !hitEmptyLine { continue }
                if line.containsOnly(" ") { hitEmptyLine = true; continue }
                return lastIndex
            }
            return lines.endIndex - 1
        }()
        return index >= 0 ? index : nil
    }
}

fileprivate extension String {
    func containsOnly(_ character: Character) -> Bool {
        for ch in self {
            if ch != character { return false }
        }
        return true
    }
}
