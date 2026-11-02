import ArgumentParser

struct PromptSummaryCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "prompt-summary",
		abstract: "Generates a summary of the current status of the checkout, usable by a command-line prompt",
	)

	func run() async throws {
		print("Foo")
	}
}
