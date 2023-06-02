import Foundation

public class CachedStreamReader {
	private var _data: Data = .init()
	var data: Data {
		get async {
			_ = await finishedTask.result
			return _data
		}
	}
	var isFinished = false
	private var finishedTask: Task<(), Never>!

	init(content: AsyncStream<Data>) {
		finishedTask = Task {
			for await data in content {
				self._data.append(data)
			}
			self.isFinished = true
		}
	}
}

extension AsyncStream where Element == Data {
	init(pipe: Pipe) {
		let fileHandle = pipe.fileHandleForReading

		self.init { continuation in
			// We need to read on a different thread, or we will deadlock
			DispatchQueue(label: "AsyncStream.initWithPipe:").async {
				repeat {
					guard
						let data = try? fileHandle.read(upToCount: 1024),
						!data.isEmpty
					else { break }

					continuation.yield(data)
				} while true

				continuation.finish()
			}
		}
	}
}
