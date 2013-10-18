#!/usr/bin/env node

var enforcedLineEnding = '\r\n'

var cp = require('child_process')

cp.exec('git rev-parse --verify HEAD', function(err) {
	var against = err ? '4b825dc642cb6eb9a060e54bf8d69288fbee4904' : 'HEAD'

	cp.exec('git diff --cached --no-color', function(err, diff) {
		var lines = diff.replace(/diff --git(.|\n)*@@.*\n/g, '')

		if(/^\+.*[^\r]?\n/m.test(lines)) return process.exit(1)

		process.exit(0)
	})
})
