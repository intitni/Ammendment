import Foundation

class IncreaseDecreaseHelper {
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
                formatter.maximumFractionDigits = 10
                formatter.minimumIntegerDigits = 1
                return "\(formatter.string(from: .init(value: val)) ?? "")"
            }
        }
    }
    
    func number(inLine line: String, from start: Int, to end: Int) -> Number? {
        let text = selectedTrimmedText(inLine: line, from: start, to: end)
        guard let double = Double(text) else { return nil }
        if text.contains(".") { return Number.floatingPoint(double) }
        return .integer(Int(double))
    }
    
    func selectedTrimmedText(inLine line: String, from start: Int, to end: Int) -> String {
        assert(end >= start)
        let index = line.indexFactory
        return String(line[index(start)..<index(end)]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updating(line: String, toIncrease increase: Bool, from start: Int, to end: Int) -> (newLine: String, newEnd: Int)? {
        guard let num = number(inLine: line, from: start, to: end) else { return nil }
        let selectedText = selectedTrimmedText(inLine: line, from: start, to: end)
        
        let updatedNum: Number = increase ? num.increased() : num.decreased()
        let index = line.indexFactory
        let newText = updatedNum.text
        return (line.replacingOccurrences(of: selectedText,
                                          with: newText,
                                          options: [],
                                          range: index(start)..<index(end)),
                end + (newText.count - selectedText.count))
    }
}
