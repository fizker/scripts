import Foundation

extension FileManager {
	private func path(for url: URL) -> String {
		let path = url.absoluteString
		let scheme = url.scheme.map { $0 + "://" } ?? ""
		let p = path[scheme.endIndex...]
		return String(p)
	}

	func fileExists(at url: URL) -> Bool {
		guard url.isFileURL
		else { return false }

		let path = path(for: url)

		return fileExists(atPath: path)
	}

	func fileStatus(atPath path: String) -> (exists: Bool, isDirectory: Bool) {
		let b: UnsafeMutablePointer<ObjCBool> = .allocate(capacity: 1)
		let exists = fileExists(atPath: path, isDirectory: b)

		return (exists, exists ? b.pointee.boolValue : false)
	}

	func isExecutableFile(at url: URL) -> Bool {
		guard url.isFileURL
		else { return false }

		let path = path(for: url)

		return isExecutableFile(atPath: path)
	}
}

public struct Command {
	public let command: URL
	public let workingDirectory: URL
	public let exists: Bool

	public static var currentWorkingDirectory: URL {
		Process().currentDirectoryURL!
	}

	public init(_ path: String, workingDirectory: URL = Command.currentWorkingDirectory) {
		self.workingDirectory = workingDirectory

		let manager = FileManager.default
		let url: URL
		if path.starts(with: "/") {
			if #available(macOS 13.0, *) {
				url = .init(filePath: path)
			} else {
				url = .init(fileURLWithPath: path)
			}
		} else if path.starts(with: ".") || path.contains("/") {
			if #available(macOS 13.0, *) {
				url = workingDirectory.appending(path: path)
			} else {
				url = workingDirectory.appendingPathComponent(path)
			}
		} else {
			var paths = ProcessInfo.processInfo.environment["PATH"]?.components(separatedBy: ":") ?? []
			paths.insert(".", at: 0)

			for p in paths {
				let file = "\(p)/\(path)"
				if !manager.fileStatus(atPath: file).isDirectory && manager.isExecutableFile(atPath: file) {
					if #available(macOS 13.0, *) {
						command = .init(filePath: file)
					} else {
						command = .init(fileURLWithPath: file)
					}
					exists = true

					return
				}
			}

			if #available(macOS 13.0, *) {
				url = .init(filePath: path)
			} else {
				url = .init(fileURLWithPath: path)
			}
		}

		exists = manager.isExecutableFile(at: url)
		command = url
	}

	public static func parseCommand(_ cmd: String) -> (command: String, arguments: [String]) {
		let all = cmd.components(separatedBy: .whitespaces)
		return (all.first ?? "", Array(all[1...]))
	}

	@discardableResult
	public func execute(arguments: [String] = []) async throws -> Result {
		try await Task {
			let process = Process()
			process.environment = ProcessInfo.processInfo.environment
			process.currentDirectoryURL = workingDirectory

			process.executableURL = command
			process.arguments = arguments

			let stdout = PipeReader()
			process.standardOutput = stdout.pipe

			let stderr = PipeReader()
			process.standardError = stderr.pipe

			try process.run()
			process.waitUntilExit()

			let exitCode = process.terminationStatus

			return Result(exitCode: Int(exitCode), stdout: stdout.data, stderr: stderr.data)
		}.result.get()
	}

	private class PipeReader {
		let pipe: Pipe
		let fileHandle: FileHandle
		private (set) var data: Data = .init()

		init(pipe: Pipe = .init()) {
			self.pipe = pipe
			fileHandle = pipe.fileHandleForReading

			DispatchQueue(label: "notification queue").async {
				repeat {
					guard
						let data = try? self.fileHandle.read(upToCount: 1024),
						!data.isEmpty
					else { break }

					self.data.append(contentsOf: data)
				} while true
			}
		}
	}

	public struct Result {
		public var exitCode: Int
		public var stdout: Data
		public var stderr: Data
	}
}
