struct GitRepo {
	enum Error: Swift.Error {
		case notRepo
		case unknown(String)
	}

	#warning("TODO: look up where git is instead of assuming")
	let git = Command("/usr/bin/git")
	var root: String

	init() async throws {
		let result = try await git.execute(arguments: ["rev-parse", "--show-toplevel"])
		guard result.exitCode == 0
		else {
			let message = String(data: try result.stderr, encoding: .utf8)!
			#warning("TODO: Use regex when new-swift is released")
			if message.contains("not") && message.contains("repo") {
				throw Error.notRepo
			}

			throw Error.unknown(message)
		}
		root = String(data: try result.stdout, encoding: .utf8)!
	}
}
