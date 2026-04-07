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
    @available(
        *,
        deprecated,
        message: "Legacy flat-child document conversion is being phased out. Use HTML.fragment { ... } for fragments or HTML.document(html:head:body:) for full documents."
    )
    public var htmlDocument: HTMLDocument {
        return HTMLDocument(children: self)
    }

    @available(
        *,
        deprecated,
        message: "Legacy flat-child document conversion is being phased out. Use HTML.fragment { ... } for fragments or HTML.document(html:head:body:) for full documents."
    )
    public var doc: HTMLDocument {
        return HTMLDocument(children: self)
    }

    @available(
        *,
        deprecated,
        message: "Legacy flat-child document conversion is being phased out. Use HTML.fragment { ... } for fragments or HTML.document(html:head:body:) for full documents."
    )
    public var document: HTMLDocument {
        return HTMLDocument(children: self)
    }

    @available(
        *,
        deprecated,
        message: "This renders through the legacy flat-child document path. Use snippet(...) for fragments or an explicit HTMLDocument."
    )
    public func render_doc(
        options: HTMLRenderOptions = .Defaults.pretty()
    ) -> String {
        return HTMLDocument(children: self).render(options: options)
    }

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
