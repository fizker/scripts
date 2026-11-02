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

		let status = try await repo.statusSummary()
		let branch = try await repo.currentBranch()?
			.color(status == .dirty ? .red : .green)

		print(" [\(branch, default: "")]")
	}
}
