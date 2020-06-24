module.exports = { trimLines }

function trimLines(strings, ...vals) {
	const content = strings.map((s, i) => `${s}${vals[i] || ""}`).join("")
	const lines = content.split("\n")

	if(lines[0] !== "") {
		throw new Error("First line must only contain whitespace")
	}

	const lastLine = lines[lines.length - 1]

	if(lastLine.trim() !== "") {
		throw new Error("Last line must only contain whitespace")
	}

	return lines.slice(1, -1).map(x => {
		if(!x.startsWith(lastLine)) {
			throw new Error("All lines must have the same indentation as the last line")
		}
		return x.slice(lastLine.length)
	}).join("\n")
}
