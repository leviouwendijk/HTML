public struct Footnote: HTMLNode, Sendable {
    public let text: String

    public init(
        _ text: String
    ) {
        self.text = text
    }

    public func render(
        options: HTMLRenderOptions,
        indent: Int
    ) -> String {
        HTMLElement(
            "sup",
            attrs: [
                "class": "footnote",
                "data-footnote": text
            ],
            children: []
        ).render(options: options, indent: indent)
    }
}
