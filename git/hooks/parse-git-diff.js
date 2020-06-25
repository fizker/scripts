module.exports = function(diff) {
	var files = diff.split(/diff --git/)
		.slice(1)
		.map(function(file) {
			const [ lineWithName, ...lines ] = file.split(/\n/)

			const contentStart = lines.findIndex(x => x.startsWith("@@")) + 1
			const metaLines = lines.splice(0, contentStart)

			const name = lineWithName.trim().replace(/^a\/(.+) b\/(?:.+)$/, '<root>/$1')
			return {
				name,
				diff: metaLines.concat(lines).join("\n"),
				lines: lines.filter(x => !x.startsWith("new file")),
				addedLines: lines.filter(x => x.startsWith('+')),
				removedLines: lines.filter(x => x.startsWith('-')),
			}
		})
		.filter(Boolean)

	return files
}
