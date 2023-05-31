import XCTest
import Shared

final class CommandTests: XCTestCase {
	func test__execute__catLargeFile__entireFileContentIsReturned() async throws {
		let exp = XCTestExpectation(description: "Loading file")
		exp.expectedFulfillmentCount = 1
		Task {
			let command = Command("/bin/cat")
			guard let file = Bundle.module.path(forResource: "BigCatTarget", ofType: nil)
			else {
				XCTFail("Could not load file")
				exp.fulfill()
				return
			}
			let result = try await command.execute(arguments: [ file ])
			exp.fulfill()

			let fileContent = FileManager.default.contents(atPath: file)

			XCTAssertEqual(result.stdout, fileContent)
			XCTAssertTrue(result.stderr.isEmpty)
		}

		await fulfillment(of: [exp], timeout: 1)
	}
}
