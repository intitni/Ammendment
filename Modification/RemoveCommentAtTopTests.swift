import XCTest
@testable import Ammendment

class RemoveCommentAtTopTests: XCTestCase {
    func testNoComment() {
        let lines = [
            "struct Cat {\n",
            "    let name: String\n",
            "}\n"
        ]
        let helper = RemoveCommentAtTopHelper()
        let index = helper.findEndLineIndexOfTopComment(from: lines)
        XCTAssertNil(index)
    }
    
    func testCommentThenCode() {
        let lines = [
            "// No one likes dogs.\n",
            "// Because everyone must love cats.\n",
            "struct Cat {\n",
            "    let name: String\n",
            "}\n"
        ]
        let helper = RemoveCommentAtTopHelper()
        let index = helper.findEndLineIndexOfTopComment(from: lines)
        XCTAssertEqual(index, 1)
    }
    
    func testCommentThenEmptyLinesThenCode() {
        let lines = [
            "// No one likes dogs.\n",                    // 0
            "// Because everyone must love cats.\n",      // 1
            "  \n",                                       // 2
            "  ",                                         // 3
            "  \n",                                       // 4
            "\n",                                         // 5
            "struct Cat {\n",
            "    let name: String\n",
            "}\n"
        ]
        let helper = RemoveCommentAtTopHelper()
        let index = helper.findEndLineIndexOfTopComment(from: lines)
        XCTAssertEqual(index, 5)
    }
    
    func testCommentThenEmptyLinesThenComment() {
        let lines = [
            "// No one likes dogs.\n",                    // 0
            "// Because everyone must love cats.\n",      // 1
            "  \n",                                       // 2
            "  ",                                         // 3
            "  \n",                                       // 4
            "\n",                                         // 5
            "// May the cats be with you.\n",
            "struct Cat {\n",
            "    let name: String\n",
            "}\n"
        ]
        let helper = RemoveCommentAtTopHelper()
        let index = helper.findEndLineIndexOfTopComment(from: lines)
        XCTAssertEqual(index, 5)
    }
}
