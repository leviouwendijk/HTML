import References

public extension HTML {
    static func cite(
        _ ref: any Referencable,
        locators: [ReferenceLocator] = [],
        comment: String? = nil
    ) -> any HTMLNode {
        Citation(
            ref,
            locators: locators,
            comment: comment
        )
    }

    static func cite(
        _ ref: any Referencable,
        at locator: ReferenceLocator,
        comment: String? = nil
    ) -> any HTMLNode {
        Citation(
            ref,
            at: locator,
            comment: comment
        )
    }

    static func cite(
        _ group: ReferenceGroup,
        comment: String? = nil
    ) -> any HTMLNode {
        HTMLInlineGroup(
            group.references.map { reference in
                Citation(
                    reference,
                    comment: comment
                )
            }
        )
    }

    static func footnote(
        _ text: String
    ) -> any HTMLNode {
        Footnote(text)
    }
}

public extension Referencable {
    func cite(
        locators: [ReferenceLocator] = [],
        comment: String? = nil
    ) -> any HTMLNode {
        HTML.cite(
            self,
            locators: locators,
            comment: comment
        )
    }

    func cite(
        at locator: ReferenceLocator,
        comment: String? = nil
    ) -> any HTMLNode {
        HTML.cite(
            self,
            at: locator,
            comment: comment
        )
    }
}
