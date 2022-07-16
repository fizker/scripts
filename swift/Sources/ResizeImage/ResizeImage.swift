import ArgumentParser
import Cocoa
import Foundation

@main
struct ResizeImage: ParsableCommand {
	enum Error: Swift.Error {
		case imageMustBeSquare
		case couldNotCreatePNGRepresentation
	}

	enum NamingStrategy: Equatable, ExpressibleByArgument {
		case appendSize(separator: String)
		case sizeOnly

		init?(argument: String) {
			switch argument {
			case "size-only":
				self = .sizeOnly
			case "append":
				self = .appendSize(separator: "_")
			default:
				return nil
			}
		}

		static let allValueStrings = [
			"append",
			"size-only",
		]

		var defaultValueDescription: String { "append" }

		func createName(base: String, size: Int) -> String {
			switch self {
			case let .appendSize(separator: separator):
				return base + separator + "\(size)"
			case .sizeOnly:
				return "\(size)"
			}
		}
	}

	@Argument(help: "The path to the image.")
	var originalImagePath: String

	@Argument(parsing: .remaining, help: "The requested sizes. At least one size must be given.")
	var requestedSizes: [Int]

	@Option(help: "The renaming strategy.")
	var namingStrategy: NamingStrategy = .appendSize(separator: "_")

	mutating func run() throws {
		try updateSizes()
	}

	func updateSizes() throws {
		let originalImagePath = URL(fileURLWithPath: originalImagePath)
		let image = NSImage(byReferencing: originalImagePath)

		guard image.size.width == image.size.height
		else { throw Error.imageMustBeSquare }

		let filename = originalImagePath.deletingPathExtension().lastPathComponent
		let basePath = originalImagePath.deletingLastPathComponent()

		let screenScale = NSScreen.main?.backingScaleFactor ?? 1

		for size in requestedSizes {
			let imageSize = CGFloat(size) / screenScale
			do {
				let resizedImage = image.resized(to: CGSize(width: imageSize, height: imageSize))
				let name = namingStrategy.createName(base: filename, size: size)
				let path = basePath.appendingPathComponent(name + ".png")
				try write(resizedImage, to: path)
			}
		}
	}

	func write(_ image: NSImage, to output: URL) throws {
		let data = image.tiffRepresentation
		let imageRep = data.flatMap(NSBitmapImageRep.init(data:))
		guard let pngRep = imageRep?.representation(using: .png, properties: [:])
		else { throw Error.couldNotCreatePNGRepresentation }
		try pngRep.write(to: output, options: [])
	}
}

extension NSImage {
	func resized(_ width: CGFloat, _ height: CGFloat) -> NSImage {
		resized(to: .init(width: width, height: height))
	}

	func resized(to newSize: CGSize) -> NSImage {
		let img = NSImage(size: newSize)

		img.lockFocus()
		defer { img.unlockFocus() }

		let ctx = NSGraphicsContext.current
		ctx?.imageInterpolation = .high

		draw(
			in: .init(origin: .zero, size: newSize),
			from: .init(origin: .zero, size: self.size),
			operation: .copy,
			fraction: 1
		)

		return img
	}
}
