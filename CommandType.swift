import Foundation
import XcodeKit

private let identifierPrefix: String = "com.intii.Ammendment.command."

protocol CommandType {
    var commandClassName: String { get }
    var identifier: String { get }
    var name: String { get }
}

extension CommandType {
    func makeCommandDefinition() -> [XCSourceEditorCommandDefinitionKey: Any] {
        return [.classNameKey: commandClassName,
                .identifierKey: identifierPrefix + identifier,
                .nameKey: name]
    }
}

func makeCommandDefinition(_ commandType: CommandType) -> [XCSourceEditorCommandDefinitionKey: Any] {
    return commandType.makeCommandDefinition()
}

extension String {
    var privateIdentifier: String {
        guard let r = range(of: identifierPrefix) else { return "" }
        let nextIndex = index(after: r.upperBound)
        return String(self[nextIndex...])
    }
}

