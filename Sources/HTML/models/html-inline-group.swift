import Foundation

public struct HTMLInlineGroup: HTMLNode {
    public let children: [any HTMLNode]

    public init(_ children: [any HTMLNode]) { self.children = children }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        var tight = options
        tight.indentation = false
        tight.newlineSeparated = false
        tight.ensureTrailingNewline = false
        return children.map { $0.render(options: tight, indent: indent) }.joined()
    }
}
