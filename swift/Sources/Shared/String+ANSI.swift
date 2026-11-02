extension String {
	public enum Color: String {
		case red, green
	}

	public func color(_ color: Color) -> String {
		return "%F{\(color.rawValue)}\(self)%f"
	}
}
