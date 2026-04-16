import Foundation

public extension HTMLDocument {
    static func parsing(
        attributes: HTMLDocumentAttributes = .empty,
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        parsing(
            attributes: attributes,
            nodes: content()
        )
    }

    @available(*, message: "Backwards compatibility. Prefer parsing(attributes:nodes:).")
    static func parsing(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        parsing(
            attributes: HTMLDocumentAttributes(
                html: attrs
            ),
            nodes: content()
        )
    }

    @available(*, message: "Backwards compatibility. Prefer parsing(attributes:nodes:).")
    static func parsing(
        html attrs: HTMLAttribute = HTMLAttribute(),
        nodes: HTMLFragment
    ) -> HTMLDocument {
        parsing(
            attributes: HTMLDocumentAttributes(
                html: attrs
            ),
            nodes: nodes
        )
    }

    static func parsing(
        attributes initialAttributes: HTMLDocumentAttributes = .empty,
        nodes: HTMLFragment
    ) -> HTMLDocument {
        var documentAttributes = initialAttributes
        var headNodes: HTMLFragment = []
        var bodyNodes: HTMLFragment = []

        func append(
            _ node: any HTMLNode,
            intoHead head: inout HTMLFragment,
            intoBody body: inout HTMLFragment
        ) {
            if node is HTMLDoctype {
                return
            }

            if let element = node as? HTMLElement {
                switch element.tag {
                case "html":
                    documentAttributes.html.merge(element.attrs)

                    for child in element.children {
                        append(
                            child,
                            intoHead: &head,
                            intoBody: &body
                        )
                    }

                case "head":
                    documentAttributes.head.merge(element.attrs)
                    head.append(contentsOf: element.children)

                case "body":
                    documentAttributes.body.merge(element.attrs)
                    body.append(contentsOf: element.children)

                default:
                    body.append(node)
                }

                return
            }

            if let inline = node as? HTMLInlineGroup {
                for child in inline.children {
                    append(
                        child,
                        intoHead: &head,
                        intoBody: &body
                    )
                }
                return
            }

            body.append(node)
        }

        for node in nodes {
            append(
                node,
                intoHead: &headNodes,
                intoBody: &bodyNodes
            )
        }

        return HTMLDocument(
            attributes: documentAttributes,
            head: headNodes,
            body: bodyNodes
        )
    }
}

public extension HTML {
    static func parsedDocument(
        attributes: HTMLDocumentAttributes = .empty,
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            attributes: attributes,
            content
        )
    }

    static func parsedDocument(
        attributes: HTMLDocumentAttributes = .empty,
        nodes: HTMLFragment
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            attributes: attributes,
            nodes: nodes
        )
    }

    @available(*, message: "Backwards compatibility. Prefer parsedDocument(attributes:...).")
    static func parsedDocument(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            html: attrs,
            content
        )
    }

    @available(*, message: "Backwards compatibility. Prefer parsedDocument(attributes:nodes:).")
    static func parsedDocument(
        html attrs: HTMLAttribute = HTMLAttribute(),
        nodes: HTMLFragment
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            html: attrs,
            nodes: nodes
        )
    }
}
