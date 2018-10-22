//
//  SourceEditorExtension.swift
//  Modification
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [JoinLines()].map(makeCommandDefinition)
             + IncreaseDecrease.Command.allCases.map(makeCommandDefinition)
    }
    
}
