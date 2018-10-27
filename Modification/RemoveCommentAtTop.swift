import Foundation

class RemoveCommentAtTopHelper {
    func findEndLineIndexOfTopComment(from lines: [String]) -> Int? {
        let index: Int = {
            var hitEmptyLine = false
            for lastIndex in -1..<lines.count {
                let i = lastIndex + 1
                let line = lines[i]
                if line.prefix(2) == "//" && !hitEmptyLine { continue }
                if line.isEmpty || line.containsOnly(charactersIn: .whitespacesAndNewlines) { hitEmptyLine = true; continue }
                return lastIndex
            }
            return lines.endIndex - 1
        }()
        return index >= 0 ? index : nil
    }
}

fileprivate extension String {
    func containsOnly(charactersIn characterSet: CharacterSet) -> Bool {
        return characterSet.isSuperset(of: .init(charactersIn: self))
    }
}
