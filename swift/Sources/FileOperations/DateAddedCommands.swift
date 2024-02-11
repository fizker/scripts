import ArgumentParser
import Foundation
import Shared

enum FileOperationError: Error {
	case notFound(String)
}

struct FileWithDateAdded: Codable {
	var path: String
	var dateAdded: Date

	static let example = #"{ "path": "some/file", "dateAdded": "2023-10-11T12:34:45Z" }"#
}

@main
struct StartCommand: ParsableCommand {
	static var configuration: CommandConfiguration = .init(
		commandName: "file-op",
		subcommands: [
			GetFileAdded.self,
			UpdateFileAdded.self,
		]
	)
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

		return try dateAdded(file: path)
	}
}


struct UpdateFileAdded: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "update",
		abstract: "Updates the dateAdded property of files.",
		usage: """
		update <file> <dateAdded>
		update <json file> [--fail-if-any-not-found|-f]
		""",
		discussion: """
		If <dateAdded> is included, <file> will be updated to match.

		If <dateAdded> is omitted, <file> will be expected to be a JSON file containing an array of items formatted like \(FileWithDateAdded.example).
		Per default, missing files are noted, but not treated as an error. The flag [--fail-if-any-not-found] treats this as an error. Note that any files already updated are not reverted.
		"""
	)

	@Argument(help: "A valid file path.")
	var file: String

	@Argument(
		help: "The date to set for the file. This must be in ISO8601 format (YYYY-MM-DDTHH:MM:SSZ).",
		transform: { input -> Date in
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			return try decoder.decode(Date.self, from: "\"\(input)\"".data(using: .utf8)!)
		}
	)
	var dateAdded: Date?

	@Flag(
		name: [ .customLong("fail-if-any-not-found"), .customShort("f") ],
		help: "If set, the program exits with an error if any of the files are missing."
	)
	var shouldFailIfFileIsMissing = false

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

		var hadError = false
		for file in files {
			do {
				try updateDateAdded(file: file.path, dateAdded: file.dateAdded)
			} catch {
				guard dateAdded == nil && !shouldFailIfFileIsMissing
				else { throw error }

				hadError = true

				print(" - \(file.path) was missing.")
			}
		}

		if hadError {
			print("All other files updated.")
		}
	}
}
