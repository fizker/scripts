const path = require("path")
const fzkes = require("fzkes")

module.exports = {
	createTestEnv,
	setupDiff,
}

function createTestEnv(fileUnderTest) {
	const console = createConsole()
	const context = createContext(console, fileUnderTest)
	const cp = createChildProcess(context)

	const exitPromise = new Promise((resolve, reject) => {
		context.process.exit.calls(resolve)
	})

	return {
		console,
		cp,
		context,
		exitPromise,
		setupDiff: (diff) => setupDiff(context, diff),
	}
}

function createConsole() {
	return Object.keys(console).reduce((o, fn) => {
		o[fn] = fzkes.fake(fn)
		return o
	}, {})
}
function createContext(console, fileUnderTest) {
	const pathToFile = path.dirname(fileUnderTest)
	return {
		require: fzkes.fake(require).calls((modulePath) => {
			if(modulePath[0] === ".") {
				modulePath = path.join(pathToFile, modulePath)
			}
			return require(modulePath)
		}),
		process: { exit: fzkes.fake("process.exit") },
		console,
	}
}
function createChildProcess(context) {
	const cp = {
		exec: fzkes.fake("exec"),
	}

	context.require.withArgs("child_process").returns(cp)

	return cp
}
function setupDiff(context, diff) {
	context.require("child_process").exec
		.withComplexArgs({ regex: /^git diff/ }).calls((command, cb) => {
			process.nextTick(() => {
				cb(null, diff)
			})
		})
}
