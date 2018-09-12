#!/usr/bin/env node

const parseDiff = require('../parse-git-diff')

var cp = require('child_process')

const utf8bom = '\ufeff'

cp.exec('git diff --cached --no-color', function(err, diff) {
	const files = parseDiff(diff)

	const filesWithBOM = files.filter(x => x.addedLines.some(x => x.includes(utf8bom)))

	if(filesWithBOM.length > 0) {
		filesWithBOM.forEach(file => {
			console.log(`${file.name} contains the UTF8 BOM. Please remove it`)
		})
		return process.exit(1)
	}

	process.exit(0)
})
