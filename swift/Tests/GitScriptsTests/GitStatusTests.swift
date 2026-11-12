import Testing
@testable import GitScripts

struct GitStatusTests {
	@Test
	func initWithStatus__multipleFiles_noBranchStatus__throws() async throws {
		#expect(throws: GitStatus.ParseError.branchLineMissing) {
			try GitStatus(status: """
			 U foo
			?? bar
			""")
		}
	}

	@Test
	func initWithStatus__multipleFiles_branchStatusLine__parsesAsExpected() async throws {
		let status = try GitStatus(status: """
		## branch
		 U foo
		?? bar
		""")

		#expect(
			status == GitStatus(
				branch: .named("branch"),
				files: [
					.init(path: "foo", status: .dirty),
					.init(path: "bar", status: .untracked),
				],
				isAhead: false,
				isBehind: false,
			)
		)
	}

	@Test
	func initWithStatus__branchHaveRemote_branchIsUpToDate__parsesAsExpected() async throws {
		let status = try GitStatus(status: """
		## branch...remoteName/remoteBranch
		 U foo
		?? bar
		""")

		#expect(
			status == GitStatus(
				branch: .named("branch"),
				files: [
					.init(path: "foo", status: .dirty),
					.init(path: "bar", status: .untracked),
				],
				isAhead: false,
				isBehind: false,
			)
		)
	}

	@Test
	func initWithStatus__multipleFiles_detachedBranch__parsesAsExpected() async throws {
		let status = try GitStatus(status: """
		## HEAD (no branch)
		 U foo
		?? bar
		""")

		#expect(
			status == GitStatus(
				branch: .detached,
				files: [
					.init(path: "foo", status: .dirty),
					.init(path: "bar", status: .untracked),
				],
				isAhead: false,
				isBehind: false,
			)
		)
	}

	@Test
	func initWithStatus__branchIsAhead__parsesAsExpected() async throws {
		let status = try GitStatus(status: "## main...origin/main [ahead 1]")

		#expect(
			status == GitStatus(
				branch: .named("main"),
				files: [],
				isAhead: true,
				isBehind: false,
			)
		)
	}

	@Test
	func initWithStatus__branchIsBehind__parsesAsExpected() async throws {
		let status = try GitStatus(status: "## main...origin/main [behind 2]")

		#expect(
			status == GitStatus(
				branch: .named("main"),
				files: [],
				isAhead: false,
				isBehind: true,
			)
		)
	}

	@Test
	func initWithStatus__branchIsBothAheadAndBehind__parsesAsExpected() async throws {
		let status = try GitStatus(status: "## main...origin/main [ahead 1, behind 2]")

		#expect(
			status == GitStatus(
				branch: .named("main"),
				files: [],
				isAhead: true,
				isBehind: true,
			)
		)
	}
}
