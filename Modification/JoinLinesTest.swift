import XCTest
import Foundation
@testable import Ammendment

class JoinLinesTests: XCTestCase {
    
    func testJoinEmpty() {
        let command = JoinLineHelper()
        let result = command.join(lines: [])
        XCTAssertEqual(result, "")
    }
    
    func testJoinOneLine() {
        let command = JoinLineHelper()
        let lines = ["hello world!\n"]
        let result = command.join(lines: lines[lines.startIndex...])
        XCTAssertEqual(result, lines.first)
    }
    
    func testJoinMultipleLines() {
        let command = JoinLineHelper()
        let lines =
            [ "hello world,",
              "hello kitty,",
              "hello moto."
            ]
        let result = command.join(lines: lines[lines.startIndex...])
        XCTAssertEqual(result, "hello world, hello kitty, hello moto.\n")
    }
    
    func testJoinMultipleLineWithLeadingTrailingSpaces() {
        let command = JoinLineHelper()
        let lines =
            [ "    hello world,  ",
              "    hello kitty,    ",
              "  hello moto."
        ]
        let result = command.join(lines: lines[lines.startIndex...])
        XCTAssertEqual(result, "    hello world, hello kitty, hello moto.\n")
    }
}
