import Foundation
import XCTest
@testable import Ammendment

typealias Number = IncreaseDecreaseHelper.Number
extension Number: Equatable {
    public static func ==(lhs: Number, rhs: Number) -> Bool {
        switch (lhs, rhs) {
        case let (.floatingPoint(l), .floatingPoint(r)) : return l == r
        case let (.integer(l), .integer(r)) : return l == r
        default: return false
        }
    }
}

class IncreaseDecreaseTests: XCTestCase {
    func testNumberIncreaseDecrease() {
        let float1_0 = Number.floatingPoint(1.0)
        XCTAssertEqual(float1_0.decreased(), Number.floatingPoint(0.9))
        XCTAssertEqual(float1_0.increased(), Number.floatingPoint(1.1))
        
        let int0 = Number.integer(0)
        XCTAssertEqual(int0.decreased(), Number.integer(-1))
        XCTAssertEqual(int0.increased(), Number.integer(1))
    }
    
    func testNumberToText() {
        XCTAssertEqual(Number.floatingPoint(0.0).text, "0.0")
        XCTAssertEqual(Number.floatingPoint(1.0).text, "1.0")
        XCTAssertEqual(Number.floatingPoint(1.1).text, "1.1")
        XCTAssertEqual(Number.floatingPoint(1.11).text, "1.11")
        XCTAssertEqual(Number.floatingPoint(-1.11).text, "-1.11")
        XCTAssertEqual(Number.floatingPoint(999.11).text, "999.11")
        XCTAssertEqual(Number.floatingPoint(-999.11).text, "-999.11")
        
        XCTAssertEqual(Number.integer(0).text, "0")
        XCTAssertEqual(Number.integer(999).text, "999")
        XCTAssertEqual(Number.integer(-999).text, "-999")
    }
    
    func testParseLineAndRangeToNumber() {
        let helper = IncreaseDecreaseHelper()
        XCTAssertEqual(helper.number(inLine: "1.0", from: 0, to: 3), Number.floatingPoint(1.0))
        XCTAssertEqual(helper.number(inLine: "1.0", from: 0, to: 1), Number.integer(1))
        XCTAssertEqual(helper.number(inLine: " 1.0", from: 0, to: 4), Number.floatingPoint(1.0))
        XCTAssertEqual(helper.number(inLine: " 1.0", from: 0, to: 2), Number.integer(1))
        XCTAssertEqual(helper.number(inLine: " 1.0 ", from: 0, to: 5), Number.floatingPoint(1.0))
        XCTAssertEqual(helper.number(inLine: " 1   ", from: 0, to: 5), Number.integer(1))
        XCTAssertEqual(helper.number(inLine: "M1.0 ", from: 0, to: 5), nil)
        XCTAssertEqual(helper.number(inLine: "M1   ", from: 0, to: 3), nil)
    }
}
