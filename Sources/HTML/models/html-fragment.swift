import Foundation

public typealias HTMLFragment = [any HTMLNode]

public struct HTMLFragmentToHTMLDocumentAPI {
    // public enum HTMLDocumentContentType {
    //     case head
    //     case body
    // }
    public let nodes: HTMLFragment
    
    public init(
        nodes: HTMLFragment
    ) {
        self.nodes = nodes
    }

    public func body(
        html attrs: HTMLAttribute = HTMLAttribute(),
        head: HTMLFragment = [],
    ) -> HTMLDocument {
        return HTMLDocument(
            html: attrs,
            head: head,
            body: self.nodes
        )
    }

    public func head(
        html attrs: HTMLAttribute = HTMLAttribute(),
        body: HTMLFragment = []
    ) -> HTMLDocument {
        return HTMLDocument(
            html: attrs,
            head: self.nodes,
            body: body
        )
    }
}

extension Array where Element == any HTMLNode {
    public func snippet(
        options: HTMLRenderOptions = .Defaults.pretty(doctype: false)
    ) -> String {
        var opts = options
        opts.doctype = false

        return self
            .map { $0.render(options: opts, indent: 0) }
            .joined()
    }

    public var `as`: HTMLFragmentToHTMLDocumentAPI {
        return .init(nodes: self)
    }
}

extension Array where Element == any HTMLNode {
    @available(
        *,
        deprecated,
        message: "Use .as.body(...) or HTML.document(html:head:body:) instead."
    )
    public var htmlDocument: HTMLDocument {
        return self.as.body()
    }

    @available(
        *,
        deprecated,
        message: "Use .as.body(...) or HTML.document(html:head:body:) instead."
    )
    public var doc: HTMLDocument {
        return self.as.body()
    }

    @available(
        *,
        deprecated,
        message: "Use .as.body(...) or HTML.document(html:head:body:) instead."
    )
    public var document: HTMLDocument {
        return self.as.body()
    }

    @available(
        *,
        deprecated,
        message: "Use snippet(...) for fragments or .as.body(...).render(...) for full documents."
    )
    public func render_doc(
        options: HTMLRenderOptions = .Defaults.pretty()
    ) -> String {
        return self.as.body().render(options: options)
    }
}
