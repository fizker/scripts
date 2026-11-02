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
		let branch = try await repo.currentBranch()?
			.color(isDirty(status) ? .red : .green)

		print(" [\(branch, default: "")]")
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
