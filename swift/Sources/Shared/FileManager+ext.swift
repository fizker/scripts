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

	public func isDirectory(atPath path: String) -> Bool {
		fileStatus(atPath: path).isDirectory
	}

	func isExecutableFile(at url: URL) -> Bool {
		guard url.isFileURL
		else { return false }

		let path = path(for: url)

		return isExecutableFile(atPath: path)
	}

	public func contentsOfDir(atPath path: String, isRecursive: Bool) throws -> [String] {
		guard isRecursive
		else { return try contentsOfDirectory(atPath: path) }

		var contents = [String]()
		for subpath in try contentsOfDirectory(atPath: path) {
			let path = path+"/"+subpath
			contents.append(path)
			if isDirectory(atPath: path) {
				contents.append(contentsOf: try contentsOfDir(atPath: path, isRecursive: true))
			}
		}
		return contents
	}
}
