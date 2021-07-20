module.exports = function(diff) {
	const files = diff.split(/^diff --git/m)
		.slice(1)
		.map(function(file) {
			const [ lineWithName, ...lines ] = file.trim().split(/\n/)

			const contentStart = lines.findIndex(x => x.startsWith("@@"))
			const metaLines = lines.splice(0, contentStart)

			const name = lineWithName.trim().replace(/^a\/(?:.+) b\/(.+)$/, '<root>/$1')
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
