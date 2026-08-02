import Foundation

public enum TokenIO {
    public static func load(from url: URL) throws -> TokenDocument {
        try decode(Data(contentsOf: url))
    }

    public static func decode(_ data: Data) throws -> TokenDocument {
        let shapeIssues = try ShapeValidator.issues(in: data)
        guard shapeIssues.isEmpty else {
            throw SkyfigValidationError(issues: shapeIssues)
        }

        let document = try JSONDecoder().decode(TokenDocument.self, from: data)
        try document.validate()
        return document
    }

    public static func canonicalData(for document: TokenDocument) throws -> Data {
        try document.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(document)
        data.append(0x0A)
        return data
    }

    public static func writeCanonical(_ document: TokenDocument, to url: URL) throws {
        let data = try canonicalData(for: document)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if (try? Data(contentsOf: url)) == data { return }
        try data.write(to: url, options: .atomic)
    }
}

public struct SkyfigValidationError: Error, CustomStringConvertible, Equatable, Sendable {
    public let issues: [String]

    public init(issues: [String]) {
        self.issues = issues.sorted()
    }

    public var description: String {
        (["Token validation failed:"] + issues.map { "- \($0)" }).joined(separator: "\n")
    }
}

extension TokenDocument {
    public func validate() throws {
        var issues: [String] = []

        if schemaVersion != "1.0.0" {
            issues.append("$.schemaVersion: expected supported version 1.0.0")
        }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("$.name: must not be empty")
        }
        if themes != ["light", "dark"] {
            issues.append("$.themes: version 1 requires [\"light\", \"dark\"] in that order")
        }
        if defaultTheme != "light" {
            issues.append("$.defaultTheme: version 1 requires \"light\"")
        }

        validatePaths(tokens.colors.keys, at: "$.tokens.colors", issues: &issues)
        validatePaths(tokens.typography.keys, at: "$.tokens.typography", issues: &issues)
        validatePaths(tokens.spacing.keys, at: "$.tokens.spacing", issues: &issues)
        validatePaths(tokens.cornerRadii.keys, at: "$.tokens.cornerRadii", issues: &issues)
        validatePaths(tokens.borderWidths.keys, at: "$.tokens.borderWidths", issues: &issues)
        validatePaths(tokens.shadows.keys, at: "$.tokens.shadows", issues: &issues)

        for (name, token) in tokens.colors {
            validateThemedColors(token.values, at: "$.tokens.colors.\(name).values", issues: &issues)
        }
        for (name, token) in tokens.typography {
            let path = "$.tokens.typography.\(name).value"
            if token.value.fontFamily.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("\(path).fontFamily: must not be empty")
            }
            validatePositive(token.value.fontSize, at: "\(path).fontSize", issues: &issues)
            if ![100, 200, 300, 400, 500, 600, 700, 800, 900].contains(token.value.fontWeight) {
                issues.append("\(path).fontWeight: must be one of 100, 200, ..., 900")
            }
            validatePositive(token.value.lineHeight, at: "\(path).lineHeight", issues: &issues)
            validateFinite(token.value.letterSpacing, at: "\(path).letterSpacing", issues: &issues)
        }
        validateDimensions(tokens.spacing, category: "spacing", issues: &issues)
        validateDimensions(tokens.cornerRadii, category: "cornerRadii", issues: &issues)
        validateDimensions(tokens.borderWidths, category: "borderWidths", issues: &issues)

        for (name, token) in tokens.shadows {
            let path = "$.tokens.shadows.\(name).value"
            if token.value.isEmpty {
                issues.append("\(path): must contain at least one shadow layer")
            }
            for (index, layer) in token.value.enumerated() {
                let layerPath = "\(path)[\(index)]"
                validateThemedColors(layer.color, at: "\(layerPath).color", issues: &issues)
                validateFinite(layer.x, at: "\(layerPath).x", issues: &issues)
                validateFinite(layer.y, at: "\(layerPath).y", issues: &issues)
                validateNonnegative(layer.blur, at: "\(layerPath).blur", issues: &issues)
                validateFinite(layer.spread, at: "\(layerPath).spread", issues: &issues)
            }
        }

        guard issues.isEmpty else { throw SkyfigValidationError(issues: issues) }
    }
}

private func validateDimensions(
    _ values: [String: DimensionToken],
    category: String,
    issues: inout [String]
) {
    for (name, token) in values {
        validateNonnegative(token.value, at: "$.tokens.\(category).\(name).value", issues: &issues)
    }
}

private func validateThemedColors(_ values: [String: String], at path: String, issues: inout [String]) {
    if Set(values.keys) != Set(["light", "dark"]) {
        issues.append("\(path): must define exactly light and dark")
    }
    for (theme, value) in values {
        if value.range(of: "^#[0-9A-F]{8}$", options: .regularExpression) == nil {
            issues.append("\(path).\(theme): expected #RRGGBBAA")
        }
    }
}

private func validatePaths<S: Sequence>(_ paths: S, at location: String, issues: inout [String]) where S.Element == String {
    var normalized: [String: String] = [:]
    let allPaths = Set(paths)
    for path in allPaths.sorted() {
        if path.range(of: "^[a-z][A-Za-z0-9]*(\\.[a-z][A-Za-z0-9]*)*$", options: .regularExpression) == nil {
            issues.append("\(location).\(path): token paths must be dot-separated lower-camel identifiers")
        }
        let emitted = path.split(separator: ".").map(String.init).map(swiftIdentifier).joined(separator: ".")
        if let existing = normalized[emitted], existing != path {
            issues.append("\(location): \(existing) and \(path) both emit as \(emitted)")
        }
        normalized[emitted] = path

        var prefix = ""
        for segment in path.split(separator: ".").dropLast() {
            prefix = prefix.isEmpty ? String(segment) : "\(prefix).\(segment)"
            if allPaths.contains(prefix) {
                issues.append("\(location): \(prefix) cannot be both a token and a namespace")
            }
        }
    }
}

private func validateFinite(_ value: Double, at path: String, issues: inout [String]) {
    if !value.isFinite { issues.append("\(path): must be finite") }
}

private func validatePositive(_ value: Double, at path: String, issues: inout [String]) {
    if !value.isFinite || value <= 0 { issues.append("\(path): must be finite and greater than zero") }
}

private func validateNonnegative(_ value: Double, at path: String, issues: inout [String]) {
    if !value.isFinite || value < 0 { issues.append("\(path): must be finite and nonnegative") }
}

private enum ShapeValidator {
    static func issues(in data: Data) throws -> [String] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ["$: expected a JSON object"]
        }
        var issues: [String] = []
        rejectUnknown(root, allowed: ["$schema", "schemaVersion", "name", "defaultTheme", "themes", "tokens"], at: "$", issues: &issues)
        guard let tokens = root["tokens"] as? [String: Any] else { return issues }
        rejectUnknown(tokens, allowed: ["colors", "typography", "spacing", "cornerRadii", "borderWidths", "shadows"], at: "$.tokens", issues: &issues)

        validateTokenMap(tokens["colors"], at: "$.tokens.colors", allowed: ["description", "values"], nestedKey: "values", nestedAllowed: nil, issues: &issues)
        validateTokenMap(tokens["typography"], at: "$.tokens.typography", allowed: ["description", "value"], nestedKey: "value", nestedAllowed: ["fontFamily", "fontSize", "fontWeight", "lineHeight", "letterSpacing"], issues: &issues)
        validateTokenMap(tokens["spacing"], at: "$.tokens.spacing", allowed: ["description", "value"], nestedKey: nil, nestedAllowed: nil, issues: &issues)
        validateTokenMap(tokens["cornerRadii"], at: "$.tokens.cornerRadii", allowed: ["description", "value"], nestedKey: nil, nestedAllowed: nil, issues: &issues)
        validateTokenMap(tokens["borderWidths"], at: "$.tokens.borderWidths", allowed: ["description", "value"], nestedKey: nil, nestedAllowed: nil, issues: &issues)

        if let shadows = tokens["shadows"] as? [String: Any] {
            for (name, rawToken) in shadows {
                guard let token = rawToken as? [String: Any] else { continue }
                let path = "$.tokens.shadows.\(name)"
                rejectUnknown(token, allowed: ["description", "value"], at: path, issues: &issues)
                if let layers = token["value"] as? [[String: Any]] {
                    for (index, layer) in layers.enumerated() {
                        rejectUnknown(layer, allowed: ["kind", "color", "x", "y", "blur", "spread"], at: "\(path).value[\(index)]", issues: &issues)
                    }
                }
            }
        }
        return issues.sorted()
    }

    private static func validateTokenMap(
        _ raw: Any?,
        at path: String,
        allowed: Set<String>,
        nestedKey: String?,
        nestedAllowed: Set<String>?,
        issues: inout [String]
    ) {
        guard let map = raw as? [String: Any] else { return }
        for (name, rawToken) in map {
            guard let token = rawToken as? [String: Any] else { continue }
            let tokenPath = "\(path).\(name)"
            rejectUnknown(token, allowed: allowed, at: tokenPath, issues: &issues)
            if let nestedKey, let nestedAllowed, let nested = token[nestedKey] as? [String: Any] {
                rejectUnknown(nested, allowed: nestedAllowed, at: "\(tokenPath).\(nestedKey)", issues: &issues)
            }
        }
    }

    private static func rejectUnknown(
        _ object: [String: Any],
        allowed: Set<String>,
        at path: String,
        issues: inout [String]
    ) {
        for key in object.keys where !allowed.contains(key) {
            issues.append("\(path).\(key): unknown property")
        }
    }
}

private let swiftKeywords: Set<String> = [
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
    "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup",
    "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var",
    "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for",
    "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "Any",
    "catch", "false", "is", "nil", "super", "self", "Self", "throw", "throws", "true", "try",
]

func swiftIdentifier(_ value: String) -> String {
    swiftKeywords.contains(value) ? "\(value)_" : value
}
