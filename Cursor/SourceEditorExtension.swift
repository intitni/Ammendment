import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return MoveCursor.Command.allCases.map(makeCommandDefinition)
             + AddCursor.Command.allCases.map(makeCommandDefinition)
    }
    
}
