//
//  SourceEditorExtension.swift
//  Cursor
//
//  Created by Shangxin Guo on 2018/10/18.
//  Copyright © 2018 Shangxin Guo. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return SourceEditorCommand.CommandType.allCases.map { type in
            return [
                .classNameKey: MoveCursor.className(),
                .identifierKey: type.identifier,
                .nameKey: type.name
            ]
        }
    }
    
}
