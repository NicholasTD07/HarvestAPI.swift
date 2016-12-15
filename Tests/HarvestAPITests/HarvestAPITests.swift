import Foundation
import XCTest

import Argo

import HarvestAPI

class HarvestAPITests: XCTestCase {
    func testDecodingProject() {
        let project: Decoded<Model.Project> = decode(json(fromFile: "project")!)

        test(decoded: project)
    }

    func testDecodingTask() {
        let task: Decoded<Model.Task> = decode(json(fromFile: "task")!)

        test(decoded: task)
    }

    func testDecodingDay() {
        let day: Decoded<Model.Day> = decode(json(fromFile: "day")!)

        test(decoded: day)
    }

    func testDecodingEntry() {
        let entry: Decoded<Model.Entry> = decode(json(fromFile: "entry")!)

        test(decoded: entry)
    }

    private func test<T>(decoded: Decoded<T>) {
        switch decoded {
        case let .success(x): XCTAssert(decoded.description == "Success(\(x))")
        default: XCTFail("Unexpected Case Occurred, \(decoded)")
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
