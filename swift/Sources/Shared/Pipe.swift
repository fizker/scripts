import Foundation

public class CachedStreamReader {
	var data: Data = .init()
	var isFinished = false

	init(content: AsyncStream<Data>) {
		Task {
			for await data in content {
				self.data.append(data)
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
