module.exports = function(diff) {
	var files = diff.split(/diff --git.*?\n/)
		.slice(1)
		.map(function(file) {
			var lines = file.split(/\n/)

			if(lines.length > 0 && lines[0].startsWith('new file')) {
				lines = lines.slice(1)
			}
			if(lines.length < 3) {
				return null
			}

			var name = lines[2].replace(/\+\+\+ .\/(.+)/, '<root>/$1')
			return {
				name: name,
				diff: file,
				lines: lines,
			}
		})

	return files
}