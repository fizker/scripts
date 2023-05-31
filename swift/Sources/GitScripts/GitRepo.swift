import Shared

struct GitRepo {
	enum Error: Swift.Error {
		case notRepo
		case unknown(String)
	}

	let git = Command("git")
	var root: String

	init() async throws {
		let result = try await git.execute(arguments: ["rev-parse", "--show-toplevel"])
		guard result.exitCode == 0
		else {
			let message = String(data: result.stderr, encoding: .utf8)!
			#warning("TODO: Use regex when new-swift is released")
			if message.contains("not") && message.contains("repo") {
				throw Error.notRepo
			}

			throw Error.unknown(message)
		}
		root = String(data: result.stdout, encoding: .utf8)!
	}
}
