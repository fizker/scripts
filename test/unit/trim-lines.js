const { trimLines } = require("../../trim-lines")

describe("unit/trim-lines.js", () => {
	describe("trimLines()", () => {
		describe("valid input", () => {
			const tests = [
				{
					description: "single line",
					input: [
						"",
						"\t\ta",
						"\t\t",
					].join("\n"),
					expected: [
						"a",
					].join("\n"),
				},
				{
					description: "multiple lines with same indentation",
					input: [
						"",
						"\t\ta",
						"\t\tb",
						"\t\t",
					].join("\n"),
					expected: [
						"a",
						"b",
					].join("\n"),
				},
				{
					description: "sub-indented line",
					input: [
						"",
						"\t\ta",
						"\t\t\tb",
						"\t\tc",
						"\t\t",
					].join("\n"),
					expected: [
						"a",
						"\tb",
						"c",
					].join("\n"),
				},
				{
					description: "no content",
					input: [
						"",
						"\t\t",
					].join("\n"),
					expected: "",
				},
			]

			for(const test of tests) {
				describe(test.description, () => {
					it("should return the expected result", () => {
						const actual = trimLines`${test.input}`
						expect(actual).to.equal(test.expected)
					})
				})
			}
		})

		describe("invalid input", () => {
			const tests = [
				{
					description: "last line contains something other than whitespace",
					input: [
						"",
						"\ta",
					].join("\n"),
					error: "Last line must only contain whitespace",
				},
				{
					description: "first line is not blank",
					input: [
						"a",
						"\t",
					].join("\n"),
					error: "First line must only contain whitespace",
				},
				{
					description: "a line is less indented than the last line",
					input: [
						"",
						"a",
						"\t",
					].join("\n"),
					error: "All lines must have the same indentation as the last line",
				},
				{
					description: "a line has different indention than the last line",
					input: [
						"",
						"  a",
						"\t",
					].join("\n"),
					error: "All lines must have the same indentation as the last line",
				},
			]

			for(const test of tests) {
				describe(test.description, () => {
					it("should throw the expected error", () => {
						expect(() => trimLines`${test.input}`).to.throw(test.error)
					})
				})
			}
		})
	})
})
