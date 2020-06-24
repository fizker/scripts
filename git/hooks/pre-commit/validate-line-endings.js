#!/usr/bin/env node

var enforcedLineEnding = '\r\n'

var cp = require('child_process')

cp.exec('git diff --cached --no-color', function(err, diff) {
	var lines = diff.replace(/diff --git(.|\n)*@@.*\n/g, '')

	if(/^\+.*[^\r]?\n/m.test(lines)) {
		console.log(`You have mixed line-endings. Please normalize to ${enforcedLineEnding.replace('\r', '\\r').replace('\n', '\\n')}.`)
		return process.exit(1)
	}

	process.exit(0)
})
