import ArgumentParser
import Foundation

@main
struct StartCommand: ParsableCommand {
	static var configuration: CommandConfiguration = .init(subcommands: [
		GetFileAdded.self,
		UpdateFileAdded.self,
	])
}

struct GetFileAdded: ParsableCommand {
	static var configuration = CommandConfiguration(commandName: "read")

	@Argument
	var file: String

	func run() throws {
		let date = try dateAdded(file: file)
		print("\(file) was added at \(date)")
	}
}


struct UpdateFileAdded: ParsableCommand {
	static var configuration = CommandConfiguration(commandName: "update")

	@Argument
	var file: String

	@Argument(transform: {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return try decoder.decode(Date.self, from: "\"\($0)\"".data(using: .utf8)!)
	})
	var date: Date

	func run() throws {
		try updateDateAdded(file: file, dateAdded: date)
	}
}
