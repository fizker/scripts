const parseGitDiff = require("../../../../git/hooks/parse-git-diff")
const { trimLines } = require("../../../../trim-lines")

// Standard git line indicators. They exist here because git does not like matching spaces and tabs for the unmodified lines
const a = "+" // added line
const r = "-" // removed line
const u = " " // unmodified line

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
						"+first line",
						"+second line",
						"\\ No newline at end of file",
					],
					addedLines: [
						"+first line",
						"+second line",
					],
					removedLines: [
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
						"-node_modules",
					],
					addedLines: [
					],
					removedLines: [
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
			${u}	const files = parseDiff(diff)
			${u}	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
			${r}
			${a}process.exit(1)
			${u}	if(filesWithBOM.length > 0) {
			${u}		filesWithBOM.forEach(file => {
			${u}			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
			`,
			expected: [
				{
					name: "<root>/git/hooks/pre-commit/utf8-bom.js",
					diff: trimLines`
					index 14e36e5..3ffc50c 100755
					--- a/git/hooks/pre-commit/utf8-bom.js
					+++ b/git/hooks/pre-commit/utf8-bom.js
					@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {
					${u}	const files = parseDiff(diff)
					${u}	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
					${r}
					${a}process.exit(1)
					${u}	if(filesWithBOM.length > 0) {
					${u}		filesWithBOM.forEach(file => {
					${u}			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
					`,
					lines: [
						" 	const files = parseDiff(diff)",
						" 	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))",
						"-",
						"+process.exit(1)",
						" 	if(filesWithBOM.length > 0) {",
						" 		filesWithBOM.forEach(file => {",
						" 			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)",
					],
					addedLines: [
						"+process.exit(1)",
					],
					removedLines: [
						"-",
					],
				},
			],
		},
		{
			description: "multiple files",
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
			diff --git a/.gitignore b/.gitignore
			deleted file mode 100644
			index 3c3629e..0000000
			--- a/.gitignore
			+++ /dev/null
			@@ -1 +0,0 @@
			-node_modules
			diff --git a/git/hooks/pre-commit/utf8-bom.js b/git/hooks/pre-commit/utf8-bom.js
			index 14e36e5..3ffc50c 100755
			--- a/git/hooks/pre-commit/utf8-bom.js
			+++ b/git/hooks/pre-commit/utf8-bom.js
			@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {
			${u}	const files = parseDiff(diff)
			${u}	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
			${r}
			${a}process.exit(1)
			${u}	if(filesWithBOM.length > 0) {
			${u}		filesWithBOM.forEach(file => {
			${u}			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
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
						"+first line",
						"+second line",
						"\\ No newline at end of file",
					],
					addedLines: [
						"+first line",
						"+second line",
					],
					removedLines: [
					],
				},
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
						"-node_modules",
					],
					addedLines: [
					],
					removedLines: [
						"-node_modules",
					],
				},
				{
					name: "<root>/git/hooks/pre-commit/utf8-bom.js",
					diff: trimLines`
					index 14e36e5..3ffc50c 100755
					--- a/git/hooks/pre-commit/utf8-bom.js
					+++ b/git/hooks/pre-commit/utf8-bom.js
					@@ -10,7 +10,7 @@ cp.exec('git diff --cached --no-color', function(err, diff) {
					${u}	const files = parseDiff(diff)
					${u}	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))
					${r}
					${a}process.exit(1)
					${u}	if(filesWithBOM.length > 0) {
					${u}		filesWithBOM.forEach(file => {
					${u}			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)
					`,
					lines: [
						" 	const files = parseDiff(diff)",
						" 	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))",
						"-",
						"+process.exit(1)",
						" 	if(filesWithBOM.length > 0) {",
						" 		filesWithBOM.forEach(file => {",
						" 			console.log(\`\${file.name} contains the UTF8 BOM. Please remove it\`)",
					],
					addedLines: [
						"+process.exit(1)",
					],
					removedLines: [
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