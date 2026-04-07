public enum DocumentRenderStyle {
    case pretty
    case minified

    public var htmlRenderOptions: HTMLRenderOptions {
        switch self {
        case .pretty:
            return HTMLRenderOptions.Defaults.pretty()
        case .minified:
            return HTMLRenderOptions.Defaults.minified()
        }
    }
}
