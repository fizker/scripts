import ArgumentParser
import Foundation
import Shared

enum FileOperationError: Error {
	case notFound(String)
}

struct FileWithDateAdded: Codable {
	var path: String
	var dateAdded: Date
}

@main
struct StartCommand: ParsableCommand {
	static var configuration: CommandConfiguration = .init(subcommands: [
		GetFileAdded.self,
		UpdateFileAdded.self,
	])
}

struct GetFileAdded: ParsableCommand {
	enum CodingKeys: CodingKey {
		case file
		case isRecursive
	}

	static var configuration = CommandConfiguration(commandName: "read")

	@Argument
	var file: String

	@Flag(name: [.customShort("r"), .customLong("recursive")])
	var isRecursive = false

	let fm = FileManager()

	func run() throws {
		var files = [file]

		if isRecursive {
			files = try fm.contentsOfDir(atPath: file, isRecursive: true)
		}

		let dates = try files.map {
			FileWithDateAdded(path: $0, dateAdded: try dateForFile(at: $0))
		}

		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(dates)
		print(String(data: data, encoding: .utf8)!)
	}

	func dateForFile(at path: String) throws -> Date {
		guard fm.fileExists(atPath: path)
		else { throw FileOperationError.notFound(path) }

		return try dateAdded(file: file)
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
