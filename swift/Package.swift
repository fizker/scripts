// swift-tools-version: 6.2

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
	.enableUpcomingFeature("ExistentialAny"),
	.enableUpcomingFeature("StrictConcurrency"),
]
let settings = upcomingFeatures + [
	.defaultIsolation(MainActor.self),
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
			swiftSettings: settings,
		),
		.executableTarget(
			name: "GitScripts",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"Shared",
			],
			swiftSettings: settings,
		),
		.executableTarget(
			name: "ReorderPaths",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: settings,
		),
		.executableTarget(
			name: "ResizeImage",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: settings,
		),
		.target(
			name: "Shared",
			swiftSettings: settings,
		),
		.target(name: "CFunctions"),
		.testTarget(
			name: "SharedTests",
			dependencies: ["Shared"],
			resources: [
				.copy("BigCatTarget"),
			],
			swiftSettings: settings,
		),
	]
)
