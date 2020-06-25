const parseGitDiff = require("../../../../git/hooks/parse-git-diff")
const { trimLines } = require("../../../../trim-lines")

describe("unit/git/hook/parse-git-diff.js", () => {
	let testData

	beforeEach(() => {
		testData = {
		}
	})

	const tests = [
		{
			description: "adding new file",
			diff: trimLines`
			diff --git a/test/unit/git/hooks/parse-git-diff.js b/test/unit/git/hooks/parse-git-diff.js
			new file mode 100644
			index 0000000..eb59b4c
			--- /dev/null
			+++ b/test/unit/git/hooks/parse-git-diff.js
			@@ -0,0 +1,20 @@
			+first line
			+second line
			\\ No newline at end of file
			`,
			expected: [
				{
					name: "<root>/test/unit/git/hooks/parse-git-diff.js",
					diff: trimLines`
					new file mode 100644
					index 0000000..eb59b4c
					--- /dev/null
					+++ b/test/unit/git/hooks/parse-git-diff.js
					@@ -0,0 +1,20 @@
					+first line
					+second line
					\\ No newline at end of file
					`,
					lines: [
						"index 0000000..eb59b4c",
						"--- /dev/null",
						"+++ b/test/unit/git/hooks/parse-git-diff.js",
						"@@ -0,0 +1,20 @@",
						"+first line",
						"+second line",
						"\\ No newline at end of file",
					],
					addedLines: [
						"+++ b/test/unit/git/hooks/parse-git-diff.js",
						"+first line",
						"+second line",
					],
					removedLines: [
						"--- /dev/null",
					],
				},
			],
		},
		{
			description: "removing file",
			diff: trimLines`
			diff --git a/.gitignore b/.gitignore
			deleted file mode 100644
			index 3c3629e..0000000
			--- a/.gitignore
			+++ /dev/null
			@@ -1 +0,0 @@
			-node_modules
			`,
			expected: [
				{
					name: "<root>/.gitignore",
					diff: trimLines`
					deleted file mode 100644
					index 3c3629e..0000000
					--- a/.gitignore
					+++ /dev/null
					@@ -1 +0,0 @@
					-node_modules
					`,
					lines: [
						"deleted file mode 100644",
						"index 3c3629e..0000000",
						"--- a/.gitignore",
						"+++ /dev/null",
						"@@ -1 +0,0 @@",
						"-node_modules",
					],
					addedLines: [
						"+++ /dev/null",
					],
					removedLines: [
						"--- a/.gitignore",
						"-node_modules",
					],
				},
			],
		},
		{
			description: "editing file",
			diff: trimLines`
			diff --git a/git/hooks/pre-commit/utf8-bom.js b/git/hooks/pre-commit/utf8-bom.js
			index 14e36e5..3ffc50c 100755
			--- a/git/hooks/pre-commit/utf8-bom.js
			+++ b/git/hooks/pre-commit/utf8-bom.js
			@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {
			 	const files = parseDiff(diff)
			 	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
			-
			+process.exit(1)
			 	if(filesWithBOM.length > 0) {
			 		filesWithBOM.forEach(file => {
			 			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
			`,
			expected: [
				{
					name: "<root>/git/hooks/pre-commit/utf8-bom.js",
					diff: trimLines`
					index 14e36e5..3ffc50c 100755
					--- a/git/hooks/pre-commit/utf8-bom.js
					+++ b/git/hooks/pre-commit/utf8-bom.js
					@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {
					 	const files = parseDiff(diff)
					 	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
					-
					+process.exit(1)
					 	if(filesWithBOM.length > 0) {
					 		filesWithBOM.forEach(file => {
					 			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
					`,
					lines: [
						"index 14e36e5..3ffc50c 100755",
						"--- a/git/hooks/pre-commit/utf8-bom.js",
						"+++ b/git/hooks/pre-commit/utf8-bom.js",
						"@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {",
						" 	const files = parseDiff(diff)",
						" 	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))",
						"-",
						"+process.exit(1)",
						" 	if(filesWithBOM.length > 0) {",
						" 		filesWithBOM.forEach(file => {",
						" 			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)",
					],
					addedLines: [
						"+++ b/git/hooks/pre-commit/utf8-bom.js",
						"+process.exit(1)",
					],
					removedLines: [
						"--- a/git/hooks/pre-commit/utf8-bom.js",
						"-",
					],
				},
			],
		},
	]

	for(const test of tests) {
		describe(test.description, () => {
			it("should create the expected diff", () => {
				const actual = parseGitDiff(test.diff)
				expect(actual).to.deep.equal(test.expected)
			})
		})
	}
})