public enum HTMLDocumentAttributeMergeStrategy: Sendable {
    case keepCurrent
    case useOther
    case mergeAppend
}

extension HTMLDocument {
    public func merging(
        with other: HTMLDocument,
        htmlAttributes strategy: HTMLDocumentAttributeMergeStrategy = .keepCurrent
    ) -> HTMLDocument {
        let attrs: HTMLAttribute

        switch strategy {
        case .keepCurrent:
            attrs = self.html_attributes

        case .useOther:
            attrs = other.html_attributes

        case .mergeAppend:
            var merged = self.html_attributes
            merged.merge(other.html_attributes)
            attrs = merged
        }

        return HTMLDocument(
            html: attrs,
            head: self.head + other.head,
            body: self.body + other.body
        )
    }
}

extension HTMLDocument {
    public func appending(
        head nodes: HTMLFragment
    ) -> HTMLDocument {
        return HTMLDocument(
            html: self.html_attributes,
            head: self.head + nodes,
            body: self.body
        )
    }

    public func appending(
        body nodes: HTMLFragment
    ) -> HTMLDocument {
        return HTMLDocument(
            html: self.html_attributes,
            head: self.head,
            body: self.body + nodes
        )
    }

    public func merging(
        with other: HTMLDocument
    ) -> HTMLDocument {
        return HTMLDocument(
            html: self.html_attributes,
            head: self.head + other.head,
            body: self.body + other.body
        )
    }
}

extension HTMLDocument {
    public func appending(
        attributes attrs: HTMLAttribute
    ) -> HTMLDocument {
        var merged = self.html_attributes
        merged.merge(attrs)

        return HTMLDocument(
            html: merged,
            head: self.head,
            body: self.body
        )
    }

    public func appendingTitle(
        _ title: String
    ) -> HTMLDocument {
        return appending(
            head: [
                HTML.title(title)
            ]
        )
    }

    public func appendingMeta(
        _ spec: HTMLMetaSpec,
        _ extra: HTMLAttribute = [:]
    ) -> HTMLDocument {
        return appending(
            head: [
                HTML.meta(spec, extra)
            ]
        )
    }
}
