describe('unit/git/hook/pre-commit/validate-line-endings.js', function() {
	var vm = require('vm')
	var fs = require('fs')
	var source = fs.readFileSync(__filename.replace('/test/unit', ''), 'utf8')
	var fakeCP
	var context
	let testData

	beforeEach(function() {
		testData = {
			fakeConsole: ['log', 'error'].reduce((o, fn) => {
				o[fn] = fzkes.fake(fn)
				return o
			}, {}),
		}

		context = {
			require: fzkes.fake(require).callsOriginal(),
			process: { exit: fzkes.fake('process.exit') },
			console: testData.fakeConsole,
		}

		fakeCP =
			{ exec: fzkes.fake('exec')
			}

		context.require.withArgs('child_process').returns(fakeCP)
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

			const promise = returnDiff(diff)
			vm.runInNewContext(source, context)
			return promise
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

			const promise = returnDiff(diff)
			vm.runInNewContext(source, context, 'text-code')
			return promise
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

			const promise = returnDiff(diff)
			vm.runInNewContext(source, context, 'text-code')
			return promise
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

			const promise = returnDiff(diff)
			vm.runInNewContext(source, context, 'text-code')
			return promise
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

			const promise = returnDiff(diff)
			vm.runInNewContext(source, context, 'text-code')
			return promise
		})
		it("should not log anything", () => {
			expect(testData.fakeConsole.log).to.not.have.been.called
			expect(testData.fakeConsole.error).to.not.have.been.called
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})

	function returnDiff(diff) {
		return new Promise((resolve, reject) => {
			fakeCP.exec
				.withComplexArgs({ regex: /^git rev-parse/ }).calls(function(command, cb) {
					process.nextTick(cb)
				})
				.withComplexArgs({ regex: /^git diff/ }).calls(function(command, cb) {
					process.nextTick(function() {
						cb(null, diff)
						resolve()
					})
				})
		})
	}
})
