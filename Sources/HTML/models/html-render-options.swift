public struct HTMLRenderOptions:
    Sendable
{
    public var doctype:
        Bool

    public var indentation:
        Bool

    public var newlineSeparated:
        Bool

    public var indentStep:
        Int

    public var attributeOrder:
        HTMLAttributeOrder

    public var ensureTrailingNewline:
        Bool

    public init(
        doctype:
            Bool = true,
        pretty:
            Bool = true,
        indentStep:
            Int = 4,
        attributeOrder:
            HTMLAttributeOrder = .preserve,
        ensureTrailingNewline:
            Bool = true
    ) {
        self.doctype =
            doctype

        self.indentation =
            pretty

        self.newlineSeparated =
            pretty

        self.indentStep =
            indentStep

        self.attributeOrder =
            attributeOrder

        self.ensureTrailingNewline =
            ensureTrailingNewline
    }

    public init(
        doctype:
            Bool = true,
        indentation:
            Bool = true,
        newlineSeparated:
            Bool = true,
        indentStep:
            Int = 4,
        attributeOrder:
            HTMLAttributeOrder = .preserve,
        ensureTrailingNewline:
            Bool = true
    ) {
        self.doctype =
            doctype

        self.indentation =
            indentation

        self.newlineSeparated =
            newlineSeparated

        self.indentStep =
            indentStep

        self.attributeOrder =
            attributeOrder

        self.ensureTrailingNewline =
            ensureTrailingNewline
    }
}

public extension HTMLRenderOptions {
    enum Defaults {
        /// Pretty HTML serialization.
        ///
        /// This policy controls representation only. Semantic inclusion has
        /// already been decided before HTML serialization.
        public static func pretty(
            doctype:
                Bool = true,
            indentStep:
                Int = 4,
            attributeOrder:
                HTMLAttributeOrder = .preserve,
            ensureTrailingNewline:
                Bool = true
        ) -> HTMLRenderOptions {
            HTMLRenderOptions(
                doctype:
                    doctype,
                pretty:
                    true,
                indentStep:
                    indentStep,
                attributeOrder:
                    attributeOrder,
                ensureTrailingNewline:
                    ensureTrailingNewline
            )
        }

        /// Compact HTML serialization.
        ///
        /// This differs from `pretty` only in textual representation.
        public static func minified(
            doctype:
                Bool = true,
            attributeOrder:
                HTMLAttributeOrder = .preserve,
            ensureTrailingNewline:
                Bool = false
        ) -> HTMLRenderOptions {
            HTMLRenderOptions(
                doctype:
                    doctype,
                indentation:
                    false,
                newlineSeparated:
                    false,
                indentStep:
                    0,
                attributeOrder:
                    attributeOrder,
                ensureTrailingNewline:
                    ensureTrailingNewline
            )
        }
    }
}
