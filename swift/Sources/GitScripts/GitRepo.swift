import Foundation
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

			if message.contains(noRepoRegex) {
				throw Error.notRepo
			}

			throw Error.unknown(message)
		}
		root = String(data: result.stdout, encoding: .utf8)!
	}

	func status() async throws -> GitStatus {
		let result = try await git.execute(arguments: [ "status", "--branch", "--porcelain" ])
		let unparsedStatus = String(data: result.stdout, encoding: .utf8) ?? ""
		var status = try GitStatus(status: unparsedStatus)

		if status.branch == .detached {
			if try await doesGitDirExist("rebase-merge", "rebase-apply") {
				status.branch = .rebasing
			}
		}

		return status
	}

	func doesGitDirExist(_ names: String...) async throws -> Bool {
		for name in names {
			let result = try await git.execute(arguments: [ "rev-parse", "--git-path", name ])
			guard let path = String(data: result.stdout, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
			else { continue }
			if FileManager.default.fileExists(atPath: path) {
				return true
			}
		}
		return false
	}
}
