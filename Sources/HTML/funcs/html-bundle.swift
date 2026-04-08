import DSL

public extension HTML {
    static func bundle<Scope: ScopeIdentifying>(
        _ scope: Scope,
        @HTMLBuilder _ body: () -> HTMLFragment
    ) -> any HTMLNode {
        HTMLBundledRegion(
            scope: scope.scope_id,
            children: body()
        )
    }

    static func bundle(
        _ scope: ScopeIdentifier,
        @HTMLBuilder _ body: () -> HTMLFragment
    ) -> any HTMLNode {
        HTMLBundledRegion(
            scope: scope,
            children: body()
        )
    }
}
