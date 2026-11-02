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

	/// Reads the name of the current branch, or `nil` if currently detached.
	/// - returns: The name of the current branch, or `nil` if currently detached.
	func currentBranch() async throws -> String? {
		let result = try await git.execute(arguments: [ "branch", "--show-current" ])
		let branch = String(data: result.stdout, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		return branch.isEmpty ? nil : branch
	}

	enum StatusSummary {
		/// There is neither dirty nor untracked changes.
		case clean
		/// There are uncommitted changes.
		case dirty
		/// If there are untracked files, but the checkout is otherwise clean.
		case untracked
	}

	func statusSummary() async throws -> StatusSummary {
		var stderr = FileHandleTextOutputStream(handle: .standardError)

		let result = try await git.execute(arguments: [ "status", "--porcelain" ])
		let status = String(data: result.stdout, encoding: .utf8) ?? ""
		let lines = status
			.components(separatedBy: .newlines)
			.map { $0.trimmingCharacters(in: .whitespaces) }
			.filter { !$0.isEmpty }

		var hasUntracked = false
		loop: for line in lines {
			switch line.first {
			case "A": // added
				return .dirty
			case "C": // copied
				return .dirty
			case "D": // deleted
				return .dirty
			case "M": // modified
				return .dirty
			case "R": // renamed
				return .dirty
			case "U": // updated but unmerged (merge conflict)
				return .dirty
			case "?": // untracked
				hasUntracked = true
			case "!": // ignored
				continue loop
			default:
				print("Unknown status marker: \(line)", to: &stderr)
				continue loop
			}
		}

		return hasUntracked ? .untracked : .clean
	}
}
