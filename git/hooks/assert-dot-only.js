const parseDiff = require('./parse-git-diff')

module.exports = function(diff) {
	var files = parseDiff(diff)
		.filter(function(file) {
			return file && file.name.match(/\.js$/)
		})
		.filter(function(file) {
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
