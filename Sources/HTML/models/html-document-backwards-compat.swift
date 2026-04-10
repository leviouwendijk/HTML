import Foundation

public extension HTML {
    @available(*, message: "Backwards compat layer, use (head:body:) init")
    static func document(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        let nodes = content()

        var headNodes: HTMLFragment = []
        var bodyNodes: HTMLFragment = []

        func append(
            _ node: any HTMLNode,
            intoHead head: inout HTMLFragment,
            intoBody body: inout HTMLFragment
        ) {
            if let element = node as? HTMLElement {
                switch element.tag {
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
