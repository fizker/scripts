module.exports = function(diff) {
	var files = diff.split(/diff --git.*?\n/)
		.slice(1)
		.map(function(file) {
			var lines = file.split(/\n/)
			if(lines.length < 3) return null
			if(lines[0].startsWith('new file')) {
				lines = lines.slice(1)
			}

			var name = lines[2].replace(/\+\+\+ .\/(.+)/, '<root>/$1')
			return {
				name: name,
				diff: file,
				lines: lines,
			}
		})
		.filter(function(file) {
			return file && file.name.match(/\.js$/)
		})

	files = files.filter(function(file) {
		return file.diff.match(/\n\+.*(describe|it)\.only/)
	})

	if(files.length) {
		var msg = files.map(function(file) {
			return '- ' + file.name
		})
		throw new Error('\n----\n'+
			'You are adding some lines containing `describe.only`\n'+
			'or `it.only` to the following files:\n'+
			msg.join('\n')+
			'\n\nPlease remove them and try again.\n----'
		)
	}
}
