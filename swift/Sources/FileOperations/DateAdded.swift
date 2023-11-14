import CFunctions
import Foundation

enum DateAddedError: Int32, Error {
	case getattrFailed = 1
	case unexpectedResponse = 2
}

func dateAdded(file: String) throws -> Date {
	let timestamp: UnsafeMutablePointer<timespec> = .allocate(capacity: 1)
	let exitCode = get_date_added(file, timestamp)

	if let error = DateAddedError(rawValue: exitCode) {
		throw error
	}

	let timespec = timestamp.pointee
	return Date(timeIntervalSince1970: TimeInterval(timespec.tv_sec))
}

enum UpdateDateAddedError: Error {
	case unknownError(Int32)
}

func updateDateAdded(file: String, dateAdded: Date) throws {
	let spec = timespec(tv_sec: Int(dateAdded.timeIntervalSince1970), tv_nsec: 0)
	let exitCode = set_date_added(file, spec)
	guard exitCode == 0
	else { throw UpdateDateAddedError.unknownError(exitCode) }
}
