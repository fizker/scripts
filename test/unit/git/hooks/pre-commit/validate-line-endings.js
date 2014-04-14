describe('unit/git/hook/pre-commit/validate-line-endings.js', function() {
	var vm = require('vm')
	var fs = require('fs')
	var Q = require('q')
	var source = fs.readFileSync(__filename.replace('/test/unit', ''), 'utf8')
		.replace(/^#/, '//')
	var fakeCP
	var context

	beforeEach(function() {
		context =
			{ require: fzkes.fake(require).callsOriginal()
			, process: { exit: fzkes.fake('process.exit') }
			, console: console
			}

		fakeCP =
			{ exec: fzkes.fake('exec')
			}

		context.require.withArgs('child_process').returns(fakeCP)
	})
	describe('When calling the script with correct newlines', function() {
		beforeEach(function(done) {
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

			returnDiff(diff).nodeify(done)
			vm.runInNewContext(source, context, 'text-code')
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})
	describe('When calling the script with incorrect newlines', function() {
		beforeEach(function(done) {
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

			returnDiff(diff).nodeify(done)
			vm.runInNewContext(source, context, 'text-code')
		})
		it('should exit with code 1', function() {
			expect(context.process.exit).to.have.been.calledWith(1)
		})
	})
	describe('When calling the script with incorrect newlines fixed', function() {
		beforeEach(function(done) {
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

			returnDiff(diff).nodeify(done)
			vm.runInNewContext(source, context, 'text-code')
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})
	describe('When calling the script with empty incorrect newlines', function() {
		beforeEach(function(done) {
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

			returnDiff(diff).nodeify(done)
			vm.runInNewContext(source, context, 'text-code')
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(1)
		})
	})
	describe('When calling the script with empty incorrect newlines fixed', function() {
		beforeEach(function(done) {
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

			returnDiff(diff).nodeify(done)
			vm.runInNewContext(source, context, 'text-code')
		})
		it('should exit with code 0', function() {
			expect(context.process.exit).to.have.been.calledWith(0)
		})
	})

	function returnDiff(diff) {
		var deferred = Q.defer()
		fakeCP.exec
			.withComplexArgs({ regex: /^git rev-parse/ }).calls(function(command, cb) {
				process.nextTick(cb)
			})
			.withComplexArgs({ regex: /^git diff/ }).calls(function(command, cb) {
				process.nextTick(function() {
					cb(null, diff)
					deferred.resolve()
				})
			})

		return deferred.promise
	}
})
