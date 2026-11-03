struct GitStatus: Equatable {
	enum Branch: Equatable {
		case detached
		case named(String)
	}

	struct File: Equatable {
		var path: String
		var status: FileStatus
	}

	enum FileStatus: Equatable {
		/// There is neither dirty nor untracked changes.
		case clean
		/// There are uncommitted changes.
		case dirty
		/// If there are untracked files, but the checkout is otherwise clean.
		case untracked
		/// The file is ignored.
		case ignored
		case unknown(String)
	}

	var branch: Branch
	var files: [File]
	var isAhead: Bool
	var isBehind: Bool
}

extension GitStatus {
	enum ParseError: Error {
		case branchLineMissing
	}

	init(status: String) throws(ParseError) {
		let lines = status
			.components(separatedBy: .newlines)
			.filter { !$0.isEmpty }

		guard let branchLine = lines.first, branchLine.hasPrefix("## ")
		else { throw .branchLineMissing }

		isAhead = branchLine.contains(/ahead \d+/)
		isBehind = branchLine.contains(/behind \d+/)

		if branchLine == "## HEAD (no branch)" {
			branch = .detached
		} else {
			let regex = /^## ([^.]+)(?:\.\.\.(?:[^ ]+)(?: \[[^\[]+\])?)?$/
			let match = branchLine.firstMatch(of: regex)?.output.1
			branch = .named(String(match!))
		}

		files = lines[1...].map { line in
			let codeStart = line.startIndex
			let codeEnd = line.index(after: codeStart)
			let pathStart = line.index(codeEnd, offsetBy: 2)

			let code = line[codeStart...codeEnd]
			let status: FileStatus = switch code {
			case " A": // added
				.dirty
			case " C": // copied
				.dirty
			case " D": // deleted
				.dirty
			case " M": // modified
				.dirty
			case " R": // renamed
				.dirty
			case " U": // updated but unmerged (merge conflict)
				.dirty
			case "??": // untracked
				.untracked
			case "!!": // ignored
				.ignored
			default:
				.unknown(String(code))
			}

			return File(path: String(line[pathStart...]), status: status)
		}
	}
}
