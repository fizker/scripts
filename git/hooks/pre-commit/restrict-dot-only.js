#!/usr/bin/env node

var assertDotOnly = require('../assert-dot-only')
var cp = require('child_process')

cp.exec('git diff --cached --no-color', function(err, diff) {
	try {
		assertDotOnly(diff)
	} catch(e) {
		console.log(e.message)
		return process.exit(1)
	}

	process.exit(0)
})
