module.exports = function(diff) {
	var files = diff.split(/diff --git/)
		.slice(1)
		.map(function(file) {
			const [ lineWithName, ...lines ] = file.split(/\n/)

			var name = lineWithName.trim().replace(/^a\/(.+) b\/(?:.+)$/, '<root>/$1')
			return {
				name: name,
				diff: lines.join("\n"),
				lines: lines.filter(x => !x.startsWith("new file")),
				addedLines: lines.filter(x => x.startsWith('+')),
				removedLines: lines.filter(x => x.startsWith('-')),
			}
		})
		.filter(Boolean)

	return files
}
