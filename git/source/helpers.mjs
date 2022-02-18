import child_process from "child_process"

const findSpacesRegex = /\s+/
export function findStartingSpaceCount(str) {
	return str.match(findSpacesRegex)?.[0]?.length ?? 0
}

class ExecError extends Error {
	constructor(err, stdout, stderr) {
		super(stderr)

		this.error = err
		this.stdout = stdout
		this.stderr = stderr
	}
}
export class NotFullyMergedError extends Error {}

export function exec(command, options) {
	return new Promise((resolve, reject) => {
		child_process.exec(command, options, (err, stdout, stderr) => {
			if(err) {
				reject(new ExecError(err, stdout, stderr))
			} else {
				resolve({ stdout, stderr })
			}
		})
	})
}

export async function getBranchList(remote = null) {
	const baseCommand = "git branch --no-color"
	const command = remote == null ? baseCommand : baseCommand + " --remote"
	const { stdout } = await exec(command)
	return stdout.split("\n")
		.map(x => x.trim())
		.filter(x => x.length > 0)
		.filter(x => remote == null
			? true
			: x.startsWith(remote + "/")
		)
		.map(branch => {
			if(branch.startsWith("*")) {
				return {
					name: branch.slice(1).trim(),
					isCurrent: true,
				}
			} else {
				return {
					name: branch,
					isCurrent: false,
				}
			}
		})
}

export async function deleteBranch(branch) {
	try {
		await exec(`git branch -d ${branch}`)
	} catch(err) {
		if(err.message.includes('not fully merged')) {
			throw new NotFullyMergedError(err.message)
		} else {
			throw err
		}
	}
}

export async function getDefaultBranch() {
	const remote = "origin"
	const allRemoteBranches = await getBranchList(remote)
	const head = allRemoteBranches.find(x => x.name.startsWith(`${remote}/HEAD`))
	if(head == null) {
		const remoteInfo = await getRemoteBranches(remote)
		// We might not have an origin. Assume main in this case
		return remoteInfo?.default ?? "main"
	}
	const [ , mainBranch ] = head.name.split("->")
	return mainBranch.trim().slice(remote.length + 1)
}

export async function getRemotes() {
	const command = "git remote"
	const { stdout } = await exec(command)
	return stdout
		.split("\n")
		.filter(Boolean)
}

export async function getRemoteBranches(remote) {
	const availableRemotes = await getRemotes()
	if(!availableRemotes.includes(remote)) {
		return null
	}

	const command = `git remote show ${remote}`
	const { stdout } = await exec(command)

	const lines = stdout.split("\n")
	const head = lines
		.find(x => x.includes("HEAD branch:"))
		?.replace("HEAD branch:", "")
		?.trim()

	const remoteBranchStartIdx = lines.findIndex(x => x.includes("Remote branch"))
	const remoteBranchStart = lines[remoteBranchStartIdx]
	const indentation = findStartingSpaceCount(remoteBranchStart)
	const remoteBranchEndIdx = lines.findIndex((x, idx) => {
		if(idx <= remoteBranchStartIdx) {
			return false
		}
		const spaces = findStartingSpaceCount(x)
		return spaces === indentation
	})

	const branchesRaw = lines.filter((x, idx) => remoteBranchStartIdx + 1 <= idx && idx < remoteBranchEndIdx)
	const branches = branchesRaw
		.map(x => {
			const [name, state] = x.trim().split(" ")
			return { name, state }
		})

	return {
		default: head,
		branches,
	}
}
