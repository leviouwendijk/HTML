import Foundation

public extension HTMLDocument {
    static func parsing(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        parsing(
            html: attrs,
            nodes: content()
        )
    }

    static func parsing(
        html attrs: HTMLAttribute = HTMLAttribute(),
        nodes: HTMLFragment
    ) -> HTMLDocument {
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
                    for child in element.children {
                        append(
                            child,
                            intoHead: &head,
                            intoBody: &body
                        )
                    }

                case "head":
                    head.append(contentsOf: element.children)

                case "body":
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
            html: attrs,
            head: headNodes,
            body: bodyNodes
        )
    }
}

public extension HTML {
    static func parsedDocument(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            html: attrs,
            content
        )
    }

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
