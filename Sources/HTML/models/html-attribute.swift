import Foundation
import DSL

public struct HTMLAttribute: ExpressibleByDictionaryLiteral, Sendable {
    private var storage: [(String, String?)] = []
    private var semanticClassStorage: Set<AnyHTMLClass> = []
    private var semanticIDStorage: Set<AnyHTMLID> = []

    public init() {}

    public init(
        dictionaryLiteral elements: (String, String)...
    ) {
        self.storage = elements.map { ($0.0, $0.1) }
    }

    public static func id(
        _ value: String
    ) -> HTMLAttribute {
        ["id": value]
    }

    public static func id<Namespace>(
        _ value: HTMLID<Namespace>
    ) -> HTMLAttribute {
        var a: HTMLAttribute = ["id": value.rawValue]
        a.semanticIDStorage.insert(value.erased)
        return a
    }

    public static func `class`(
        _ classes: [String]
    ) -> HTMLAttribute {
        ["class": classes.joined(separator: " ")]
    }

    public static func `class`(
        _ value: String
    ) -> HTMLAttribute {
        ["class": value]
    }

    public static func `class`(
        _ classes: [HTMLClassToken]
    ) -> HTMLAttribute {
        var a: HTMLAttribute = [
            "class": classes.map(\.rawValue).joined(separator: " ")
        ]
        a.semanticClassStorage.formUnion(
            classes.compactMap(\.semanticValue)
        )
        return a
    }

    public static func `class`(
        _ classes: HTMLClassToken...
    ) -> HTMLAttribute {
        .class(classes)
    }

    public static func `class`<Namespace>(
        _ value: HTMLClass<Namespace>
    ) -> HTMLAttribute {
        .class([value.token])
    }

    public static func `class`<Namespace>(
        _ classes: [HTMLClass<Namespace>]
    ) -> HTMLAttribute {
        .class(
            classes.map(\.token)
        )
    }

    public static func classes(
        base: [AnyHTMLClass],
        appending extra: [HTMLClassToken] = []
    ) -> HTMLAttribute {
        .class(
            base.map(HTMLClassToken.semantic) + extra
        )
    }

    public static func `for`<Namespace>(
        _ value: HTMLID<Namespace>
    ) -> HTMLAttribute {
        ["for": value.rawValue]
    }

    public static func data(
        _ key: String,
        _ value: String
    ) -> HTMLAttribute {
        ["data-\(key)": value]
    }

    public static func aria(
        _ key: String,
        _ value: String
    ) -> HTMLAttribute {
        ["aria-\(key)": value]
    }

    public static func bool(
        _ key: String,
        _ enabled: Bool
    ) -> HTMLAttribute {
        var a = HTMLAttribute()
        if enabled {
            a.storage.append((key, nil))
        }
        return a
    }

    public static func type(
        _ value: String
    ) -> HTMLAttribute {
        ["type": value]
    }

    public static func href(
        _ value: String
    ) -> HTMLAttribute {
        ["href": value]
    }

    public mutating func merge(
        _ other: HTMLAttribute
    ) {
        storage.append(contentsOf: other.storage)
        semanticClassStorage.formUnion(other.semanticClassStorage)
        semanticIDStorage.formUnion(other.semanticIDStorage)
    }

    public func render() -> String {
        render(order: .ranked)
    }

    public func render(
        order: HTMLAttributeOrder
    ) -> String {
        guard !storage.isEmpty else {
            return ""
        }

        let ordered: [(String, String?)]

        switch order {
        case .preserve:
            ordered = storage

        case .ranked:
            @inline(__always)
            func keyRank(
                _ key: String
            ) -> (Int, String) {
                switch key {
                case "id":
                    return (0, key)
                case "class":
                    return (1, key)
                case "src":
                    return (2, key)
                case "href":
                    return (3, key)
                case "alt":
                    return (4, key)
                case "type":
                    return (5, key)
                case "name":
                    return (6, key)
                case "value":
                    return (7, key)
                case "width":
                    return (8, key)
                case "height":
                    return (9, key)
                case "style":
                    return (10, key)
                default:
                    if key.hasPrefix("data-") {
                        return (20, key)
                    }

                    if key.hasPrefix("aria-") {
                        return (30, key)
                    }

                    return (40, key)
                }
            }

            ordered = storage.sorted { lhs, rhs in
                let (lr, lk) = keyRank(lhs.0)
                let (rr, rk) = keyRank(rhs.0)
                return (lr, lk) < (rr, rk)
            }

        case .custom(let cmp):
            let enumerated = Array(storage.enumerated())
            let sorted = enumerated.sorted { lhs, rhs in
                let lk = lhs.element.0
                let rk = rhs.element.0

                if lk == rk {
                    return lhs.offset < rhs.offset
                }

                return cmp(lk, rk)
            }

            ordered = sorted.map(\.element)
        }

        var parts: [String] = []
        parts.reserveCapacity(ordered.count)

        for (key, value) in ordered {
            if let value {
                parts.append("\(key)=\"\(htmlEscape(value))\"")
            } else {
                parts.append(key)
            }
        }

        return parts.joined(separator: " ")
    }

    public func values(
        for key: String
    ) -> [String] {
        storage.compactMap { storedKey, storedValue in
            guard storedKey == key else {
                return nil
            }

            return storedValue ?? ""
        }
    }

    public func value(
        for key: String
    ) -> String? {
        values(for: key).last
    }

    public var classList: [String] {
        values(for: "class")
            .flatMap { raw in
                raw.split(whereSeparator: {
                    $0 == " " || $0 == "\t" || $0 == "\n" || $0 == "\r"
                }).map(String.init)
            }
            .filter { !$0.isEmpty }
    }

    public var rawClassNames: Set<String> {
        Set(classList)
    }

    public var rawIDNames: Set<String> {
        Set(
            values(for: "id")
                .filter { !$0.isEmpty }
        )
    }

    public var semanticClasses: Set<AnyHTMLClass> {
        semanticClassStorage
    }

    public var semanticIDs: Set<AnyHTMLID> {
        semanticIDStorage
    }
}

// public struct HTMLAttribute: ExpressibleByDictionaryLiteral, Sendable {
//     private var storage: [(String, String?)] = []

//     public init() {}

//     public init(dictionaryLiteral elements: (String, String)...) {
//         self.storage = elements.map { ($0.0, $0.1) }
//     }

//     // public init(_ elements: [String: String]) {
//     //     self.storage = elements.map { ($0.0, $0.1) }
//     // }

//     public static func id(_ value: String) -> HTMLAttribute { ["id": value] }
//     public static func `class`(_ classes: [String]) -> HTMLAttribute { ["class": classes.joined(separator: " ")] }
//     public static func data(_ key: String, _ value: String) -> HTMLAttribute { ["data-\(key)": value] }
//     public static func aria(_ key: String, _ value: String) -> HTMLAttribute { ["aria-\(key)": value] }
//     public static func bool(_ key: String, _ enabled: Bool) -> HTMLAttribute {
//         var a = HTMLAttribute()
//         if enabled { a.storage.append((key, nil)) }
//         return a
//     }

//     public static func type(_ value: String) -> HTMLAttribute { ["type": value] }
//     public static func href(_ value: String) -> HTMLAttribute { ["href": value] }

//     public mutating func merge(_ other: HTMLAttribute) {
//         storage.append(contentsOf: other.storage)
//     }

//     /// Back-compat: existing API keeps "ranked" as default behavior.
//     public func render() -> String {
//         render(order: .ranked)
//     }

//     /// Order-aware rendering. `.ranked` preserves the old implementation.
//     public func render(order: HTMLAttributeOrder) -> String {
//         guard !storage.isEmpty else { return "" }

//         let ordered: [(String, String?)]

//         switch order {
//         case .preserve:
//             ordered = storage

//         case .ranked:
//             // Original behavior (unchanged)
//             @inline(__always)
//             func keyRank(_ k: String) -> (Int, String) {
//                 // 0 = highest priority, larger = lower
//                 switch k {
//                 case "id": return (0, k)
//                 case "class": return (1, k)
//                 case "src": return (2, k)
//                 case "href": return (3, k)
//                 case "alt": return (4, k)
//                 case "type": return (5, k)
//                 case "name": return (6, k)
//                 case "value": return (7, k)
//                 case "width": return (8, k)
//                 case "height": return (9, k)
//                 case "style": return (10, k)
//                 default:
//                     if k.hasPrefix("data-") { return (20, k) }
//                     if k.hasPrefix("aria-") { return (30, k) }
//                     return (40, k)
//                 }
//             }

//             ordered = storage.sorted { (a, b) in
//                 let (ra, sa) = keyRank(a.0)
//                 let (rb, sb) = keyRank(b.0)
//                 return (ra, sa) < (rb, sb)
//             }

//         case .custom(let cmp):
//             // Deterministic: if keys are equal, keep insertion order.
//             let enumerated = Array(storage.enumerated())
//             let sorted = enumerated.sorted { lhs, rhs in
//                 let lk = lhs.element.0
//                 let rk = rhs.element.0
//                 if lk == rk { return lhs.offset < rhs.offset }
//                 return cmp(lk, rk)
//             }
//             ordered = sorted.map { $0.element }
//         }

//         var parts: [String] = []
//         parts.reserveCapacity(ordered.count)
//         for (k, v) in ordered {
//             if let v {
//                 parts.append("\(k)=\"\(htmlEscape(v))\"")
//             } else {
//                 parts.append(k)
//             }
//         }
//         return parts.joined(separator: " ")
//     }

//     public static func `class`(_ s: String) -> HTMLAttribute { ["class": s] }
// }

// extension HTMLAttribute {
//     /// Return the last value for a given attribute key, if any.
//     public func value(for key: String) -> String? {
//         for (k, v) in storage.reversed() where k == key {
//             return v ?? ""
//         }
//         return nil
//     }

//     /// Convenience: split the `class` attribute into individual class names.
//     public var classList: [String] {
//         guard let raw = value(for: "class") else { return [] }
//         return raw
//             .split(whereSeparator: { $0 == " " || $0 == "\t" || $0 == "\n" || $0 == "\r" })
//             .map(String.init)
//             .filter { !$0.isEmpty }
//     }
// }
