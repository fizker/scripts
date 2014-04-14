#!/usr/bin/env node

var assertDotOnly = require('../assert-dot-only')
var cp = require('child_process')

cp.exec('git rev-parse --verify HEAD', function(err) {
	var against = err ? '4b825dc642cb6eb9a060e54bf8d69288fbee4904' : 'HEAD'

	cp.exec('git diff --cached --no-color', function(err, diff) {
		try {
			assertDotOnly(diff)
		} catch(e) {
			console.log(e.message)
			return process.exit(1)
		}

		process.exit(0)
	})
})
