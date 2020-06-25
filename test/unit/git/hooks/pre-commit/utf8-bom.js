const vm = require("vm")
const fs = require("fs")
const fileUnderTest = __filename.replace("/test/unit", "")
const source = fs.readFileSync(fileUnderTest, "utf8")
const helpers = require("../../../../../test-helpers")
const { trimLines } = require("../../../../../trim-lines")

describe("unit/git/hook/pre-commit/utf8-bom.js", () => {
	let testData

	beforeEach(() => {
		testData = {
			...helpers.createTestEnv(fileUnderTest),
		}
	})

	const tests = [
		{
			description: "new file without bom",
			diff: trimLines`
			diff --git a/test/unit/git/hooks/parse-git-diff.js b/test/unit/git/hooks/parse-git-diff.js
			new file mode 100644
			index 0000000..eb59b4c
			--- /dev/null
			+++ b/test/unit/git/hooks/parse-git-diff.js
			@@ -0,0 +1,20 @@
			+first line
			+second line
			`,
			expectedExitCode: 0,
		},
		{
			description: "new file with bom",
			diff: trimLines`
			diff --git a/test/unit/git/hooks/parse-git-diff.js b/test/unit/git/hooks/parse-git-diff.js
			new file mode 100644
			index 0000000..eb59b4c
			--- /dev/null
			+++ b/test/unit/git/hooks/parse-git-diff.js
			@@ -0,0 +1,20 @@
			+\ufefffirst line
			+second line
			`,
			expectedExitCode: 1,
		},
	]

	for(const test of tests) {
		describe(test.description, () => {
			beforeEach(() => {
				testData.setupDiff(test.diff)
				vm.runInNewContext(source, testData.context)
			})
			it(`should return status code ${test.expectedExitCode}`, async () => {
				expect(await testData.exitPromise).to.equal(test.expectedExitCode)
			})
		})
	}
})
