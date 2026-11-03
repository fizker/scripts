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
			)
		)
	}
}
