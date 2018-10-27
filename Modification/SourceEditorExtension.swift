import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [RemoveCommnetAtTop(), JoinLines()].map(makeCommandDefinition)
             + IncreaseDecrease.Command.allCases.map(makeCommandDefinition)
             + Stash.Command.allCases.map(makeCommandDefinition)
    }
    
}
