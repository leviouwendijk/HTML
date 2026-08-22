import Foundation

public enum HTMLPlainTextCollector {
    public struct Options: Sendable {
        public var separator: String
        public var collapseWhitespace: Bool
        public var includeImageAltText: Bool
        public var maxLength: Int?
        public var truncationSuffix: String

        public init(
            separator: String = " ",
            collapseWhitespace: Bool = true,
            includeImageAltText: Bool = true,
            maxLength: Int? = nil,
            truncationSuffix: String = ""
        ) {
            self.separator = separator
            self.collapseWhitespace = collapseWhitespace
            self.includeImageAltText = includeImageAltText
            self.maxLength = maxLength
            self.truncationSuffix = truncationSuffix
        }
    }

    public static func collect(
        from nodes: HTMLFragment,
        options: Options = .init()
    ) -> String {
        var parts: [String] = []
        parts.reserveCapacity(nodes.count)

        for node in nodes {
            append(node, into: &parts, options: options)
        }

        var out = parts.joined()

        if options.collapseWhitespace {
            out = collapseWS(out)
        }

        if let max = options.maxLength, out.count > max {
            out = truncate(out, max: max, suffix: options.truncationSuffix)
        }

        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func append(
        _ node: any HTMLNode,
        into parts: inout [String],
        options: Options
    ) {
        switch node {
        case let t as HTMLText:
            parts.append(t.text)

        case let r as HTMLRaw:
            let stripped = stripTags(r.html)
            if !stripped.isEmpty {
                parts.append(htmlUnescape(stripped))
            }
        case _ as HTMLComment:
            break

        case _ as HTMLDoctype:
            break

        case _ as HTMLNewline:
            parts.append(options.separator)

        case let inline as HTMLInlineGroup:
            for child in inline.children {
                append(child, into: &parts, options: options)
            }

        case let el as HTMLElement:
            let tag = el.tag.lowercased()

            if isBlockish(tag) {
                parts.append(options.separator)
            } else if tag == "br" {
                parts.append(options.separator)
                return
            }

            if tag == "img", options.includeImageAltText {
                if let alt = el.attrs.value(for: "alt"), !alt.isEmpty {
                    parts.append(alt)
                    parts.append(options.separator)
                }
            }

            for child in el.children {
                append(child, into: &parts, options: options)
            }

            if isBlockish(tag) {
                parts.append(options.separator)
            }

        case let region as HTMLBundledRegion:
            for child in region.children {
                append(child, into: &parts, options: options)
            }

        default:
            break
        }
    }

    private static func isBlockish(_ tag: String) -> Bool {
        switch tag {
        case "p", "div", "section", "article", "header", "footer", "nav",
             "main", "aside", "ul", "ol", "li", "dl", "dt", "dd",
             "h1", "h2", "h3", "h4", "h5", "h6",
             "blockquote", "pre", "figure", "figcaption",
             "table", "thead", "tbody", "tfoot", "tr", "td", "th",
             "hr":
            return true
        default:
            return false
        }
    }

    private static func collapseWS(_ s: String) -> String {
        var out = ""
        out.reserveCapacity(s.count)

        var lastWasWS = false
        for ch in s {
            if ch.isWhitespace || ch.isNewline {
                if !lastWasWS {
                    out.append(" ")
                    lastWasWS = true
                }
            } else {
                out.append(ch)
                lastWasWS = false
            }
        }

        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func truncate(_ s: String, max: Int, suffix: String) -> String {
        guard max > 0 else { return "" }
        let limit = max - suffix.count
        guard limit > 0 else { return String(s.prefix(max)) }

        let prefix = String(s.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
        return prefix + suffix
    }

    private static func stripTags(_ html: String) -> String {
        var out = ""
        out.reserveCapacity(html.count)

        var inTag = false
        for ch in html {
            if ch == "<" {
                inTag = true
                continue
            }
            if ch == ">" {
                inTag = false
                continue
            }
            if !inTag {
                out.append(ch)
            }
        }

        return out
    }

    /// Minimal entity decode for meta-description use.
    private static func htmlUnescape(_ s: String) -> String {
        guard s.contains("&") else { return s }

        var out = ""
        out.reserveCapacity(s.count)

        var i = s.startIndex
        while i < s.endIndex {
            let ch = s[i]
            if ch != "&" {
                out.append(ch)
                i = s.index(after: i)
                continue
            }

            // try parse entity up to ';'
            guard let semi = s[i...].firstIndex(of: ";") else {
                out.append(ch)
                i = s.index(after: i)
                continue
            }

            let entity = String(s[s.index(after: i)..<semi])
            if let decoded = decodeEntity(entity) {
                out.append(decoded)
                i = s.index(after: semi)
            } else {
                out.append("&")
                i = s.index(after: i)
            }
        }

        return out
    }

    private static func decodeEntity(_ e: String) -> Character? {
        switch e {
        case "amp": return "&"
        case "lt": return "<"
        case "gt": return ">"
        case "quot": return "\""
        case "#39": return "'"
        default:
            break
        }

        // numeric: #123 or #x7B
        if e.hasPrefix("#x") || e.hasPrefix("#X") {
            let hex = e.dropFirst(2)
            guard let v = UInt32(hex, radix: 16),
                  let scalar = UnicodeScalar(v) else { return nil }
            return Character(scalar)
        }

        if e.hasPrefix("#") {
            let dec = e.dropFirst(1)
            guard let v = UInt32(dec, radix: 10),
                  let scalar = UnicodeScalar(v) else { return nil }
            return Character(scalar)
        }

        return nil
    }
}

public extension Array where Element == any HTMLNode {
    func plaintext(
        options: HTMLPlainTextCollector.Options = .init()
    ) -> String {
        HTMLPlainTextCollector.collect(from: self, options: options)
    }
}
