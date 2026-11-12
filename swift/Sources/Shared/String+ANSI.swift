extension String {
	public enum Color: String {
		case red, green
	}

	public func color(_ color: Color) -> String {
		return "%F{\(color.rawValue)}\(self)%f"
	}

	public func italic() -> String {
		let esc = "\u{1B}"
		return "\(esc)[3m\(self)\(esc)[23m"
	}
}
