import ArgumentParser
import Foundation
import Shared

enum FileOperationError: Error {
	case notFound(String)
}

struct FileWithDateAdded: Codable {
	var path: String
	var dateAdded: Date

	static let example = #"{"path":"some/file","dateAdded":"2023-10-11T12:34:45Z"}"#
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
	var dateAdded: Date?

	func run() throws {
		let files: [FileWithDateAdded]

		if let dateAdded {
			files = [.init(path: file, dateAdded: dateAdded)]
		} else {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			do {
				let data = try Data(contentsOf: URL(filePath: file))
				files = try decoder.decode([FileWithDateAdded].self, from: data)
			} catch {
				print("Error: The provided file was not a valid list of paths and dates. The expected format is [\(FileWithDateAdded.example),...].")
				print(StartCommand.helpMessage(for: UpdateFileAdded.self))
				throw ExitCode.validationFailure
			}
		}

		for file in files {
			try updateDateAdded(file: file.path, dateAdded: file.dateAdded)
		}
	}
}
