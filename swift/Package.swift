// swift-tools-version: 6.2

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
	.enableUpcomingFeature("ExistentialAny"),
	.enableUpcomingFeature("StrictConcurrency"),
]

let package = Package(
	name: "swift",
	platforms: [
		.macOS(.v13),
	],
	products: [
		.executable(
			name: "file-op",
			targets: ["FileOperations"]
		),
		.executable(
			name: "git-scripts",
			targets: ["GitScripts"]
		),
		.executable(
			name: "reorder-paths",
			targets: ["ReorderPaths"]
		),
		.executable(
			name: "resize-image",
			targets: ["ResizeImage"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
	],
	targets: [
		.executableTarget(
			name: "FileOperations",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"Shared",
				"CFunctions",
			],
			swiftSettings: upcomingFeatures
		),
		.executableTarget(
			name: "GitScripts",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"Shared",
			],
			swiftSettings: upcomingFeatures
		),
		.executableTarget(
			name: "ReorderPaths",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: upcomingFeatures
		),
		.executableTarget(
			name: "ResizeImage",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: upcomingFeatures
		),
		.target(
			name: "Shared",
			swiftSettings: upcomingFeatures
		),
		.target(name: "CFunctions"),
		.testTarget(
			name: "SharedTests",
			dependencies: ["Shared"],
			resources: [
				.copy("BigCatTarget"),
			],
			swiftSettings: upcomingFeatures
		),
	]
)
