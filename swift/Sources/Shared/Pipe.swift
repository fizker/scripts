import Foundation

func consume(stream: AsyncStream<Data>) async -> Data {
	var data = Data()
	for await chunk in stream {
		data.append(chunk)
	}
	return data
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
