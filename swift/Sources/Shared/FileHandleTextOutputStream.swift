public import Foundation

public struct FileHandleTextOutputStream: TextOutputStream {
	let handle: FileHandle

	public init(handle: FileHandle) {
		self.handle = handle
	}

	public func write(_ string: String) {
		if let data = string.data(using: .utf8) {
			handle.write(data)
		}
	}
}
