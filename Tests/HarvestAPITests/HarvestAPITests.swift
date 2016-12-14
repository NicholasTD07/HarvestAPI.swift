import Foundation
import XCTest
import HarvestAPI

class HarvestAPITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(HarvestAPI().text, "Hello, World!")
    }
}

#if os(Linux)
extension HarvestAPITests {
    static var allTests : [(String, (HarvestAPITests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
