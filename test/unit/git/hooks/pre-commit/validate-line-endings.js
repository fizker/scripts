const helpers = require("../../../../../test-helpers")

describe('unit/git/hook/pre-commit/validate-line-endings.js', function() {
	var vm = require('vm')
	var fs = require('fs')
	var source = fs.readFileSync(__filename.replace('/test/unit', ''), 'utf8')
	var fakeCP
	var context
	let testData

	beforeEach(function() {
		const env = helpers.createTestEnv()
		context = env.context
		fakeCP = env.cp

		testData = {
			fakeConsole: env.console,
			setupDiff: env.setupDiff,
			exitPromise: env.exitPromise,
		}
	})
	describe('When calling the script with correct newlines', function() {
		beforeEach(() => {
			var diff =
			      'diff --git a/file b/file\n'
			    + 'index abc..def 100644\n'
			    + '--- a/file\n'
			    + '+++ b/file\n'
			    + '@@ -1,3 +1,3 @@\n'
			    + ' context before\r\n'
			    + '-old line\r\n'
			    + '+new line\r\n'
			    + ' context after\r\n'

			testData.setupDiff(diff)
			vm.runInNewContext(source, context)
			return testData.exitPromise
		})
		it("should not log anything", () => {
			expect(testData.fakeConsole.log).to.not.have.been.called
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})
	describe('When calling the script with incorrect newlines', function() {
		beforeEach(() => {
			var diff =
			      'diff --git a/file b/file\n'
			    + 'index abc..def 100644\n'
			    + '--- a/file\n'
			    + '+++ b/file\n'
			    + '@@ -1,3 +1,3 @@\n'
			    + ' context before\n'
			    + '-old line\n'
			    + '+new line\n'
			    + ' context after\n'

			testData.setupDiff(diff)
			vm.runInNewContext(source, context)
			return testData.exitPromise
		})
		it("should log error message", () => {
			expect(testData.fakeConsole.log).to.have.been.calledWith("You have mixed line-endings. Please normalize to \\r\\n.")
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 1', function() {
			expect(context.process.exit).to.have.been.calledWith(1)
		})
	})
	describe('When calling the script with incorrect newlines fixed', function() {
		beforeEach(() => {
			var diff =
			      'diff --git a/file b/file\n'
			    + 'index abc..def 100644\n'
			    + '--- a/file\n'
			    + '+++ b/file\n'
			    + '@@ -1,3 +1,3 @@\n'
			    + ' context before\r\n'
			    + '-old line\n'
			    + '+new line\r\n'
			    + ' context after\r\n'

			testData.setupDiff(diff)
			vm.runInNewContext(source, context)
			return testData.exitPromise
		})
		it("should not log anything", () => {
			expect(testData.fakeConsole.log).to.not.have.been.called
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})
	describe('When calling the script with empty incorrect newlines', function() {
		beforeEach(() => {
			var diff =
			      'diff --git a/file b/file\n'
			    + 'index abc..def 100644\n'
			    + '--- a/file\n'
			    + '+++ b/file\n'
			    + '@@ -1,3 +1,3 @@\n'
			    + ' context before\r\n'
			    + '-\n'
			    + '+\n'
			    + ' context after\r\n'

			testData.setupDiff(diff)
			vm.runInNewContext(source, context)
			return testData.exitPromise
		})
		it("should log error message", () => {
			expect(testData.fakeConsole.log).to.have.been.calledWith("You have mixed line-endings. Please normalize to \\r\\n.")
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 1', function() {
			expect(context.process.exit).to.have.been.calledWith(1)
		})
	})
	describe('When calling the script with empty incorrect newlines fixed', function() {
		beforeEach(() => {
			var diff =
			      'diff --git a/file b/file\n'
			    + 'index abc..def 100644\n'
			    + '--- a/file\n'
			    + '+++ b/file\n'
			    + '@@ -1,3 +1,3 @@\n'
			    + ' context before\r\n'
			    + '-\n'
			    + '+\r\n'
			    + ' context after\r\n'

			testData.setupDiff(diff)
			vm.runInNewContext(source, context)
			return testData.exitPromise
		})
		it("should not log anything", () => {
			expect(testData.fakeConsole.log).to.not.have.been.called
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})
})
