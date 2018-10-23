import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [JoinLines()].map(makeCommandDefinition)
             + IncreaseDecrease.Command.allCases.map(makeCommandDefinition)
    }
    
}
