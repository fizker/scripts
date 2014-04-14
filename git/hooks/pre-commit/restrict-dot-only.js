#!/usr/bin/env node

var cp = require('child_process')

cp.exec('git rev-parse --verify HEAD', function(err) {
	var against = err ? '4b825dc642cb6eb9a060e54bf8d69288fbee4904' : 'HEAD'

	cp.exec('git diff --cached --no-color', function(err, diff) {
		var files = diff.split(/diff --git.*?\n/)
			.slice(1)
			.map(function(file) {
				var lines = file.split(/\n/)
				var name = lines[2].replace(/\+\+\+ .*\/(.+)/, '$1')
				return {
					name: name,
					diff: file,
					lines: lines,
				}
			})
			.filter(function(file) {
				return file.name.match(/\.js$/)
			})

		files.filter(function(file) {
			return !checkFile(file)
		})
		if(files.length) {
			var msg = files.map(function(file) {
				return '- ' + file.name
			})
			console.log('\n----\n'+
				'You are adding some lines containing `describe.only`'+
				' or `it.only` to the following files:\n'+
				msg.join('\n')+
				'\n\nPlease remove them and try again.\n----'
			)
			return process.exit(1)
		}

		process.exit(0)
	})
})

function checkFile(file) {
	return !file.diff.match(/\n+.*(describe|it)\.only/)
}
