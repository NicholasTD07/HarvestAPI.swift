import Foundation
import XCTest

import Argo

import HarvestAPI

class HarvestAPITests: XCTestCase {
    func testDecodingProject() {
        let project: Decoded<Model.Project> = decode(json(fromFile: "project")!)

        test(decoded: project)
    }

    private func test<T>(decoded: Decoded<T>) {
        switch decoded {
        case let .success(x): XCTAssert(decoded.description == "Success(\(x))")
        default: XCTFail("Unexpected Case Occurred")
        }
    }
}

#if os(Linux)
extension HarvestAPITests {
    static var allTests : [(String, (HarvestAPITests) -> () throws -> Void)] {
        return [
            /* ("testExample", testExample), */
        ]
    }
}
#endif
