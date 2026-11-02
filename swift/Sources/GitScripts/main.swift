import ArgumentParser
import Cocoa
import Foundation

@main
struct GitScripts: AsyncParsableCommand {
	static let configuration = CommandConfiguration(subcommands: [
		PromptSummaryCommand.self,
		TestAllCommand.self,
	])
}
