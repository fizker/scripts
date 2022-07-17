// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "swift",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.executable(
			name: "git-scripts",
			targets: ["GitScripts"]
		),
		.executable(
			name: "resize-image",
			targets: ["ResizeImage"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.1.2")),
	],
	targets: [
		.executableTarget(
			name: "GitScripts",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.executableTarget(
			name: "ResizeImage",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
	]
)
