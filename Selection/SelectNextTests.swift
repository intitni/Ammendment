import XCTest
import Foundation
@testable import Ammendment

class SelectNextTests: XCTestCase {
    func testGetSelectType() {
        
    }
    
    func testGetSelectionsCoveringWordsUnderCursors() {
        
    }
    
    func testGetNextOccurrenceOfSingleLine() {
        
    }
    
    func testMatchNextSelection() {
        let helper = SelectNextHelper()
        XCTAssertTrue(helper.matchNextSelection(
            ["   hello!\n",
             "pikachu",
             "  world  !\n"],
            toPreviousLines:
            ["hello!\n",
             "pikachu",
             "  world  !\n"],
            startColumn: 0, endColumn: 10
        ))
        
        XCTAssertTrue(helper.matchNextSelection(
            ["   hello!\n",
             "pikachu",
             "  world  !\n"],
            toPreviousLines:
            ["hello!\n",
             "pikachu",
             "  world  !\n"],
            startColumn: 4, endColumn: 7
        ))
        
        XCTAssertFalse(helper.matchNextSelection(
            ["   hello!\n",
             "pikachu",
             "    world  !\n"],
            toPreviousLines:
            ["hello!\n",
             "pikachu",
             "  world  !\n"],
            startColumn: 4, endColumn: 7
        ))
        
        XCTAssertFalse(helper.matchNextSelection(
            ["   hello!\n",
             "pikachu"],
            toPreviousLines:
            ["hello!\n",
             "pikachu",
             "  world  !\n"],
            startColumn: 4, endColumn: 7
        ))
        
        XCTAssertFalse(helper.matchNextSelection(
            ["   hello!\n",
             "pikachu",
             "  world  !\n"],
            toPreviousLines:
            ["hello!\n",
             "snoopy",
             "  world  !\n"
            ],
            startColumn: 4, endColumn: 7
        ))
    }
    
    func testGetNextOccurrenceOfMultiLine() {
        
    }
}
