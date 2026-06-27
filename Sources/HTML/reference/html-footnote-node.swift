public struct Footnote: HTMLNode, Sendable {
    public let content: HTMLFragment

    public var text: String {
        content.plaintext()
    }

    public init(
        _ text: String
    ) {
        self.content = [
            HTMLText(text)
        ]
    }

    public init(
        content: HTMLFragment
    ) {
        self.content = content
    }

    public init(
        @HTMLBuilder _ content: () -> HTMLFragment
    ) {
        self.content = content()
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
