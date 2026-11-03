import ArgumentParser
import Shared

struct PromptSummaryCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "prompt-summary",
		abstract: "Generates a summary of the current status of the checkout, usable by a command-line prompt",
	)

	func run() async throws {
		let repo: GitRepo
		do {
			repo = try await GitRepo()
		} catch GitRepo.Error.notRepo {
			return
		}

		let status = try await repo.status()
		let branch = switch status.branch {
			case .detached: "detached".italic()
			case let .named(name): name
		}

		let remoteStatus = switch (status.isAhead, status.isBehind) {
		case (false, false): ""
		case (true, false): " ↑"
		case (false, true): " ↓"
		case (true, true): " ↑↓"
		}

		print(" [\(branch.color(isDirty(status) ? .red : .green))\(remoteStatus)]")
	}

	func isDirty(_ status: GitStatus) -> Bool {
		var stderr = FileHandleTextOutputStream(handle: .standardError)

		for file in status.files {
			switch file.status {
			case .dirty:
				return true
			case .clean, .ignored, .untracked:
				break
			case .unknown(let code):
				print("Unknown status marker: \(code) \(file.path)", to: &stderr)
			}
		}
		return false
	}
}
