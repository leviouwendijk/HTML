import Foundation
import DSL

public struct HTMLBundledRegion: HTMLNode {
    public let scope: ScopeIdentifier
    public let children: HTMLFragment

    public init(
        scope: ScopeIdentifier,
        children: HTMLFragment
    ) {
        self.scope = scope
        self.children = children
    }

    public func render(
        options: HTMLRenderOptions,
        indent: Int
    ) -> String {
        children
            .map { $0.render(options: options, indent: indent) }
            .joined()
    }
}
