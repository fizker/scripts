import Foundation

public struct Command: Sendable {
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

			let stdout = Pipe()
			process.standardOutput = stdout
			let stdoutData = AsyncStream(pipe: stdout)

			let stderr = Pipe()
			process.standardError = stderr
			let stderrData = AsyncStream(pipe: stderr)

			try process.run()
			process.waitUntilExit()

			let exitCode = process.terminationStatus

			return Result(exitCode: Int(exitCode), stdout: await consume(stream: stdoutData), stderr: await consume(stream: stderrData))
		}.result.get()
	}

	public struct Result: Sendable {
		public var exitCode: Int
		public var stdout: Data
		public var stderr: Data
	}
}
