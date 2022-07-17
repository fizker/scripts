import Foundation

struct Command {
	var path: String
	var workingDirectory: String

	private var exists: Bool?

	static var currentWorkingDirectory: String {
		#warning("TODO: Implement currentDirectory")
		return ""
	}

	init(_ path: String, workingDirectory: String = Command.currentWorkingDirectory) {
		self.path = path
		self.workingDirectory = workingDirectory
	}

	mutating func exists() async -> Bool {
		if let exists = exists {
			return exists
		}

		let manager = FileManager.default
		let result = manager.fileExists(atPath: path)
		exists = result
		return result
	}

	@discardableResult
	func execute(arguments: [String] = []) async throws -> Result {
		try await Task {
			let process = Process()
			if #available(macOS 13.0, *) {
				process.executableURL = .init(filePath: path)
			} else {
				process.executableURL = .init(fileURLWithPath: path)
			}
			process.arguments = arguments

			let stdout = Pipe()
			process.standardOutput = stdout

			let stderr = Pipe()
			process.standardError = stderr

			try process.run()
			process.waitUntilExit()

			let exitCode = process.terminationStatus

			return Result(exitCode: Int(exitCode), stdout: stdout, stderr: stderr)
		}.result.get()
	}

	struct Result {
		var exitCode: Int

		private var stdoutPipe: PipeCache
		private var stderrPipe: PipeCache

		var stdout: Data {
			get throws { try stdoutPipe.data }
		}
		var stderr: Data {
			get throws { try stderrPipe.data }
		}

		init(exitCode: Int, stdout: Pipe, stderr: Pipe) {
			self.exitCode = exitCode
			self.stdoutPipe = .init(pipe: stdout)
			self.stderrPipe = .init(pipe: stderr)
		}

		class PipeCache {
			let pipe: Pipe
			var data: Data {
				get throws {
					if let data = cachedData {
						return data
					}
					let file = pipe.fileHandleForReading
					let data = try file.readToEnd() ?? Data()
					cachedData = data
					return data
				}
			}
			private var cachedData: Data?

			init(pipe: Pipe) {
				self.pipe = pipe
			}
		}
	}
}
