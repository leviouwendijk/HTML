public enum HTMLDocumentAttributeMergeStrategy: Sendable {
    case keepCurrent
    case useOther
    case mergeAppend
}

extension HTMLDocumentAttributes {
    public func merging(
        with other: HTMLDocumentAttributes,
        strategy: HTMLDocumentAttributeMergeStrategy = .mergeAppend
    ) -> HTMLDocumentAttributes {
        switch strategy {
        case .keepCurrent:
            return self

        case .useOther:
            return other

        case .mergeAppend:
            var html = self.html
            var head = self.head
            var body = self.body

            html.merge(other.html)
            head.merge(other.head)
            body.merge(other.body)

            return HTMLDocumentAttributes(
                html: html,
                head: head,
                body: body
            )
        }
    }
}

extension HTMLDocument {
    public func merging(
        with other: HTMLDocument,
        attributes strategy: HTMLDocumentAttributeMergeStrategy = .mergeAppend
    ) -> HTMLDocument {
        HTMLDocument(
            attributes: self.attributes.merging(
                with: other.attributes,
                strategy: strategy
            ),
            head: self.head + other.head,
            body: self.body + other.body
        )
    }

    @available(*, message: "Backwards compatibility. Prefer merging(with:attributes:).")
    public func merging(
        with other: HTMLDocument,
        htmlAttributes strategy: HTMLDocumentAttributeMergeStrategy
    ) -> HTMLDocument {
        let html: HTMLAttribute

        switch strategy {
        case .keepCurrent:
            html = self.attributes.html

        case .useOther:
            html = other.attributes.html

        case .mergeAppend:
            var merged = self.attributes.html
            merged.merge(other.attributes.html)
            html = merged
        }

        var mergedAttributes = self.attributes.merging(
            with: other.attributes,
            strategy: .mergeAppend
        )
        mergedAttributes.html = html

        return HTMLDocument(
            attributes: mergedAttributes,
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
            attributes: self.attributes,
            head: self.head + nodes,
            body: self.body
        )
    }

    public func appending(
        body nodes: HTMLFragment
    ) -> HTMLDocument {
        return HTMLDocument(
            attributes: self.attributes,
            head: self.head,
            body: self.body + nodes
        )
    }

    public func appending(
        attributes attrs: HTMLDocumentAttributes
    ) -> HTMLDocument {
        return HTMLDocument(
            attributes: self.attributes.merging(
                with: attrs,
                strategy: .mergeAppend
            ),
            head: self.head,
            body: self.body
        )
    }

    @available(*, message: "Backwards compatibility. Prefer appending(attributes: HTMLDocumentAttributes).")
    public func appending(
        attributes attrs: HTMLAttribute
    ) -> HTMLDocument {
        var merged = self.attributes
        merged.html.merge(attrs)

        return HTMLDocument(
            attributes: merged,
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
