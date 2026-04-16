import Methods
import Primitives

public struct HTMLDocumentAttributes: Sendable {
    public var html: HTMLAttribute
    public var head: HTMLAttribute
    public var body: HTMLAttribute

    public init(
        html: HTMLAttribute = HTMLAttribute(),
        head: HTMLAttribute = HTMLAttribute(),
        body: HTMLAttribute = HTMLAttribute()
    ) {
        self.html = html
        self.head = head
        self.body = body
    }

    public static let empty = HTMLDocumentAttributes()
}

public struct HTMLDocument: Sendable {
    public var attributes: HTMLDocumentAttributes
    public var head: HTMLFragment
    public var body: HTMLFragment

    public init(
        attributes: HTMLDocumentAttributes = .empty,
        head: HTMLFragment = [],
        body: HTMLFragment = []
    ) {
        self.attributes = attributes
        self.head = head
        self.body = body
    }

    @available(*, message: "Backwards compatibility. Prefer init(attributes:head:body:).")
    public init(
        html html_attributes: HTMLAttribute = HTMLAttribute(),
        head: HTMLFragment = [],
        body: HTMLFragment = []
    ) {
        self.init(
            attributes: HTMLDocumentAttributes(
                html: html_attributes
            ),
            head: head,
            body: body
        )
    }

    @available(*, message: "Backwards compatibility. Prefer init(attributes:head:body:).")
    public init(
        children: HTMLFragment
    ) {
        self.init(
            attributes: .empty,
            head: [],
            body: children
        )
    }
}

public extension HTMLDocument {
    @available(*, message: "Backwards compatibility. Prefer attributes.html.")
    var html_attributes: HTMLAttribute {
        get {
            attributes.html
        }
        set {
            attributes.html = newValue
        }
    }

    @available(*, message: "Backwards compatibility. Prefer attributes.head.")
    var head_attributes: HTMLAttribute {
        get {
            attributes.head
        }
        set {
            attributes.head = newValue
        }
    }

    @available(*, message: "Backwards compatibility. Prefer attributes.body.")
    var body_attributes: HTMLAttribute {
        get {
            attributes.body
        }
        set {
            attributes.body = newValue
        }
    }
}

extension HTMLDocument {
    @available(
        *,
        deprecated,
        message: "Legacy flat-child documents are being phased out. Use html/head/body instead."
    )
    public var children: HTMLFragment {
        return document_tree
    }
}

extension HTMLDocument {
    internal var document_tree: HTMLFragment {
        return [
            HTML.html(attributes.html) {
                HTML.head(attributes.head) {
                    head
                }
                HTML.body(attributes.body) {
                    body
                }
            }
        ]
    }

    public func render(
        options: HTMLRenderOptions = .init()
    ) -> String {
        var out: String = ""

        if options.doctype {
            out += HTMLDoctype(.html5)
                .render(options: options)
        }

        let content = document_tree
            .map { $0.render(options: options, indent: 0) }
            .joined()

        out += content

        if options.ensureTrailingNewline, !out.hasSuffix("\n") {
            out.append("\n")
        }

        return out
    }
}

extension HTMLDocument {
    public typealias RenderDefault = DocumentRenderStyle

    public func render(
        default: DocumentRenderStyle = .pretty,
        doctype: Bool? = nil,
        indentStep: Int? = nil,
        attributeOrder: HTMLAttributeOrder? = nil,
        ensureTrailingNewline: Bool? = nil,
        environment: BuildEnvironment? = nil,
        onGate: (@Sendable (GateEvent) -> Void)? = nil
    ) -> String {
        var opts = HTMLRenderOptions()
        opts = `default`.htmlRenderOptions

        doctype.ifNotNil { value in
            opts.doctype = value
        }

        indentStep.ifNotNil { value in
            opts.indentStep = value
        }

        attributeOrder.ifNotNil { value in
            opts.attributeOrder = value
        }

        ensureTrailingNewline.ifNotNil { value in
            opts.ensureTrailingNewline = value
        }

        environment.ifNotNil { value in
            opts.environment = value
        }

        opts.onGate = onGate

        return render(options: opts)
    }
}

extension HTMLDocument {
    public static func basic(
        lang: String? = nil,
        title: String? = nil,
        stylesheets: [String] = [],
        inlineStyle: String? = nil,
        @HTMLBuilder body: () -> [any HTMLNode]
    ) -> HTMLDocument {
        var headNodes: HTMLFragment = [
            HTML.meta(.charset()),
            HTML.meta(.viewport())
        ]

        if let title {
            headNodes.append(
                HTML.title(title)
            )
        }

        for href in stylesheets {
            headNodes.append(
                HTML.link(.stylesheet(href: href))
            )
        }

        if let css = inlineStyle {
            headNodes.append(
                HTML.style(css)
            )
        }

        return HTMLDocument(
            html: lang.map { ["lang": $0] } ?? HTMLAttribute(),
            head: headNodes,
            body: body()
        )
    }
}
