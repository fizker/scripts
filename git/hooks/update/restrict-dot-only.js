#!/usr/bin/env node

var assertDotOnly = require('../assert-dot-only')
var cp = require('child_process')

var firstCommit = process.argv[3]
var lastCommit = process.argv[4]

console.log('git diff --cached --no-color '+firstCommit+'..'+lastCommit)

cp.exec('git diff --no-color '+firstCommit+'..'+lastCommit, function(err, diff) {
	try {
		assertDotOnly(diff)
	} catch(e) {
		console.log(e.message)
		return process.exit(1)
	}

	process.exit(1)
	process.exit(0)
})
