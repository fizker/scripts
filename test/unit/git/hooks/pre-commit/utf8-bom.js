const vm = require("vm")
const fs = require("fs")
const fileUnderTest = __filename.replace("/test/unit", "")
const source = fs.readFileSync(fileUnderTest, "utf8")
const helpers = require("../../../../../test-helpers")
const { trimLines } = require("../../../../../trim-lines")

const a = "+" // added line
const r = "-" // removed line
const u = " " // unmodified line
const utf8BOM = "\ufeff"

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
			expectedErrorFiles: [
			],
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
			+${utf8BOM}first line
			+second line
			`,
			expectedExitCode: 1,
			expectedErrorFiles: [
				"/test/unit/git/hooks/parse-git-diff.js"
			],
		},
		{
			description: "renamed file",
			diff: trimLines`
			diff --git a/web/Medconnect.Web/Data/ApplicationDbContext.cs b/web/Medconnect.Data/ApplicationDbContext.cs
			similarity index 85%
			rename from web/Medconnect.Web/Data/ApplicationDbContext.cs
			rename to web/Medconnect.Data/ApplicationDbContext.cs
			index f3f93b4..a92ab1b 100644
			--- a/web/Medconnect.Web/Data/ApplicationDbContext.cs
			+++ b/web/Medconnect.Data/ApplicationDbContext.cs
			@@ -1,12 +1,11 @@
			${r}using System;
			${a}${utf8BOM}using System;
			${u}using System.Collections.Generic;
			${u}using System.Text;
			${r}using Medconnect.Data;
			${u}using Microsoft.AspNetCore.Identity;
			${u}using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
			${u}using Microsoft.EntityFrameworkCore;
			${u}
			${r}namespace Medconnect.Web.Data
			${a}namespace Medconnect.Data
			${u}{
			${u}	public class ApplicationDbContext : IdentityDbContext<ApplicationUser, IdentityRole<int>, int>
			${u}	{
			`,
			expectedExitCode: 1,
			expectedErrorFiles: [
				"/web/Medconnect.Data/ApplicationDbContext.cs"
			],
		},
	]

	for(const test of tests) {
		describe(test.description, () => {
			beforeEach(() => {
				testData.setupDiff(test.diff)
				vm.runInNewContext(source, testData.context)
				return testData.exitPromise
			})
			it(`should return status code ${test.expectedExitCode}`, async () => {
				expect(await testData.exitPromise).to.equal(test.expectedExitCode)
			})
			it("should report the expected files as changed", async () => {
				if(test.expectedExitCode === 0) {
					expect(testData.console.log).to.not.have.been.called
				} else {
					const expectedOutput = test.expectedErrorFiles.map(
						file => `<root>${file} contains the UTF8 BOM. Please remove it`
					).join("\n")
					expect(testData.console.log).to.have.been.calledWith(expectedOutput)
				}

				expect(testData.console.error).to.not.have.been.called
			})
		})
	}
})
