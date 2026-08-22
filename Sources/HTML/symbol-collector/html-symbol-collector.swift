import Foundation
import DSL

public struct HTMLSymbols: Sendable, Equatable {
    public var semanticClasses: Set<AnyHTMLClass>
    public var semanticIDs: Set<AnyHTMLID>
    public var rawClasses: Set<String>
    public var rawIDs: Set<String>

    public init(
        semanticClasses: Set<AnyHTMLClass> = [],
        semanticIDs: Set<AnyHTMLID> = [],
        rawClasses: Set<String> = [],
        rawIDs: Set<String> = []
    ) {
        self.semanticClasses = semanticClasses
        self.semanticIDs = semanticIDs
        self.rawClasses = rawClasses
        self.rawIDs = rawIDs
    }

    public var classes: Set<String> {
        rawClasses.union(
            semanticClasses.map(\.rawValue)
        )
    }

    public var ids: Set<String> {
        rawIDs.union(
            semanticIDs.map(\.rawValue)
        )
    }
}

public enum HTMLSymbolCollector {
    public static func collect(
        from nodes: HTMLFragment
    ) -> HTMLSymbols {
        var result = HTMLSymbols()

        for node in nodes {
            collect(node, into: &result)
        }

        return result
    }

    private static func collect(
        _ node: any HTMLNode,
        into result: inout HTMLSymbols
    ) {
        switch node {
        case let el as HTMLElement:
            result.semanticClasses.formUnion(el.attrs.semanticClasses)
            result.semanticIDs.formUnion(el.attrs.semanticIDs)
            result.rawClasses.formUnion(el.attrs.rawClassNames)
            result.rawIDs.formUnion(el.attrs.rawIDNames)

            for child in el.children {
                collect(child, into: &result)
            }

        case let inline as HTMLInlineGroup:
            for child in inline.children {
                collect(child, into: &result)
            }

        case let region as HTMLBundledRegion:
            for child in region.children {
                collect(child, into: &result)
            }

        default:
            break
        }
    }
}
