import ArgumentParser
import Cocoa
import Foundation

@main
struct GitScripts: AsyncParsableCommand {
	mutating func run() async throws {
		let repo = try await GitRepo()
		print(repo.root)
	}
}
