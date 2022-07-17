import ArgumentParser
import Foundation
import Shared

struct TestAllCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "test-all",
		abstract: "Run the given commands, executes them all and repeats the output from any that failed."
	)

	@Flag()
	var includeHooksPath = false

	@Option(name: [ .customLong("command"), .short ], parsing: .singleValue)
	var commands: [String]

	@Argument()
	var arguments: [String] = []

	func run() async throws {
		var errors: [String] = []

		var commands = commands

		if includeHooksPath {
			let git = Command("git")
			let result = try await git.execute(arguments: ["config", "--get-all", "fizker.hooksPath"])
			if result.exitCode == 0 {
				let raw = try result.stdout
				if let str = String(data: raw, encoding: .utf8) {
					let items = str
						.components(separatedBy: .newlines)
						.joined(separator: ":")
						.components(separatedBy: CharacterSet(charactersIn: ":"))

					commands.append(contentsOf: items)
				}
			}
		}

		for path in commands where !path.isEmpty {
			let command = Command(path)

			if command.exists {
				let result = try await command.execute(arguments: arguments)
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
