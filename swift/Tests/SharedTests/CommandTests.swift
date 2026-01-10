import Foundation
import Testing
import Shared

struct CommandTests {
	enum BundleError: Error {
		case couldNotFindResource
	}

	@Test
	func execute__catLargeFile__entireFileContentIsReturned() async throws {
		guard let file = Bundle.module.path(forResource: "BigCatTarget", ofType: nil)
		else { throw BundleError.couldNotFindResource }
		let fileContent = FileManager.default.contents(atPath: file)

		let command = Command("/bin/cat")
		let result = try await command.execute(arguments: [ file ])

		#expect(result.stdout == fileContent)
		#expect(result.stderr.isEmpty)
	}
}
