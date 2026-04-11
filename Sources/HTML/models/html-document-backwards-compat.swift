import Foundation

public extension HTML {
    @available(*, message: "Backwards compat layer, use HTMLDocument.parsing(...) or HTML.document(html:head:body:)")
    static func document(
        html attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> HTMLDocument {
        HTMLDocument.parsing(
            html: attrs,
            content
        )
    }
}
