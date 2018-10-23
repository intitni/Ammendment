import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [SelectLine(), SelectNext()].map(makeCommandDefinition)
    }
    
}
