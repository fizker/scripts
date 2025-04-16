import Shared

nonisolated(unsafe) // regex literals are always safe, but compiler does not know
let noRepoRegex = /not a .*repo/

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

			let match = try noRepoRegex.wholeMatch(in: message)
			if match != nil {
				throw Error.notRepo
			}

			throw Error.unknown(message)
		}
		root = String(data: result.stdout, encoding: .utf8)!
	}
}
