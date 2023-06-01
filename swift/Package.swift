// swift-tools-version: 5.8

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
	.enableUpcomingFeature("ConciseMagicFile"),
	.enableUpcomingFeature("ForwardTrailingClosures"),
	.enableUpcomingFeature("ExistentialAny"),
	.enableUpcomingFeature("StrictConcurrency"),
	.enableUpcomingFeature("ImplicitOpenExistentials"),
	.enableUpcomingFeature("BareSlashRegexLiterals"),
]

let package = Package(
	name: "swift",
	platforms: [
		.macOS(.v13),
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
				"Shared",
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
