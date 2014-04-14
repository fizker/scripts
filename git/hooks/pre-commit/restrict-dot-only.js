#!/usr/bin/env node

var cp = require('child_process')

cp.exec('git rev-parse --verify HEAD', function(err) {
	var against = err ? '4b825dc642cb6eb9a060e54bf8d69288fbee4904' : 'HEAD'

	cp.exec('git diff --cached --no-color', function(err, diff) {
		if(diff.match(/\n+.*(describe|it)\.only/)) {
			console.log('\n----\nYou are adding some lines containing `describe.only`'+
				' or `it.only`.\nPlease remove them and try again.\n----')
			return process.exit(1)
		}

		process.exit(0)
	})
})
