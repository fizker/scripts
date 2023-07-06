import ArgumentParser
import Cocoa
import Foundation

@main
struct ReorderPaths: ParsableCommand {
	@Option(help: "The pattern to search for.")
	var pattern: String

	mutating func run() throws {
		let pi = ProcessInfo.processInfo
		guard let p = pi.environment["PATH"]
		else { return }

		var path = Path(raw: p)

		path.prioritizePaths(matching: pattern)

		print(path.asRaw)
	}
}

struct Path {
	var paths: [String]

	mutating func prioritizePaths(matching pattern: String) {
		let priority = paths.filter { $0.contains(pattern) }
		let other = paths.filter { !$0.contains(pattern) }

		paths = priority + other
	}
}

extension Path {
	init(raw: String) {
		paths = raw.components(separatedBy: ":")
	}

	var asRaw: String {
		paths.joined(separator: ":")
	}
}
