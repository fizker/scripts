import ArgumentParser
import Foundation
import Shared

struct TestAllCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "test-all",
		abstract: "Run the given commands, executes them all and repeats the output from any that failed."
	)

	@Argument()
	var commands: [String]

	struct E: Error, LocalizedError {
		let errorDescription: String?
	}

	func run() async throws {
		var errors: [String] = []

		for raw in commands {
			let parsed = Command.parseCommand(raw)
			let command = Command(parsed.command)

			if command.exists {
				let result = try await command.execute(arguments: parsed.arguments)
				if result.exitCode != 0 {
					var data = try result.stderr
					if data.isEmpty {
						data = try result.stdout
					}
					let message = String(data: data, encoding: .utf8)!
					errors.append(message.trimmingCharacters(in: .whitespacesAndNewlines))
				}
			}
		}

		guard !errors.isEmpty
		else { return }

		print(errors.joined(separator: "\n"))
		Foundation.exit(1)
	}
}
