import Foundation
import CoreFoundation

public enum FigmaImporter {
    public static func importVariables(from data: Data, name: String = "Skyfig Figma Tokens") throws -> TokenDocument {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let meta = root["meta"] as? [String: Any],
            let variables = meta["variables"] as? [String: Any],
            let collections = meta["variableCollections"] as? [String: Any]
        else {
            throw FigmaImportError.invalidPayload("expected meta.variables and meta.variableCollections from the Figma Variables API")
        }

        let resolver = Resolver(variables: variables, collections: collections)
        var colors: [String: ColorToken] = [:]
        var spacing: [String: DimensionToken] = [:]
        var cornerRadii: [String: DimensionToken] = [:]
        var borderWidths: [String: DimensionToken] = [:]
        var typographyBuilders: [String: TypographyBuilder] = [:]
        var shadowBuilders: [String: [Int: ShadowBuilder]] = [:]
        var importedNames: [String: String] = [:]

        for id in variables.keys.sorted() {
            guard let variable = variables[id] as? [String: Any], let rawName = variable["name"] as? String else {
                throw FigmaImportError.invalidVariable(id)
            }
            if variable["deletedButReferenced"] as? Bool == true { continue }
            let parts = canonicalParts(rawName)
            guard !parts.isEmpty else { throw FigmaImportError.unsupportedName(rawName) }
            let category = categoryName(parts[0])
            let resolvedType = (variable["resolvedType"] as? String)?.uppercased() ?? ""
            if let importKey = try canonicalImportKey(
                category: category,
                resolvedType: resolvedType,
                parts: parts,
                source: rawName
            ) {
                try claim(importKey, source: rawName, importedNames: &importedNames)
            }

            switch category {
            case "typography":
                try importTypography(id: id, name: rawName, parts: parts, resolver: resolver, builders: &typographyBuilders)
            case "shadow", "shadows":
                try importShadow(id: id, name: rawName, parts: parts, resolver: resolver, builders: &shadowBuilders)
            case "spacing":
                let path = try tokenPath(parts.dropFirst(), source: rawName)
                spacing[path] = DimensionToken(description: variable["description"] as? String, value: try resolver.number(id: id, theme: "light"))
            case "cornerradius", "cornerradii", "radius", "radii":
                let path = try tokenPath(parts.dropFirst(), source: rawName)
                cornerRadii[path] = DimensionToken(description: variable["description"] as? String, value: try resolver.number(id: id, theme: "light"))
            case "borderwidth", "borderwidths":
                let path = try tokenPath(parts.dropFirst(), source: rawName)
                borderWidths[path] = DimensionToken(description: variable["description"] as? String, value: try resolver.number(id: id, theme: "light"))
            default:
                guard resolvedType == "COLOR" else { continue }
                let colorParts = ["color", "colors"].contains(category) ? parts.dropFirst() : parts[...]
                let path = try tokenPath(colorParts, source: rawName)
                colors[path] = ColorToken(
                    description: variable["description"] as? String,
                    values: [
                        "light": try resolver.color(id: id, theme: "light"),
                        "dark": try resolver.color(id: id, theme: "dark"),
                    ]
                )
            }
        }

        let typography = try typographyBuilders.mapValues { try $0.build() }
        let shadows = try shadowBuilders.mapValues { indexed in
            let layers = try indexed.keys.sorted().map { try indexed[$0]!.build() }
            return ShadowToken(value: layers)
        }
        let document = TokenDocument(
            name: name,
            tokens: TokenCollection(
                colors: colors,
                typography: typography,
                spacing: spacing,
                cornerRadii: cornerRadii,
                borderWidths: borderWidths,
                shadows: shadows
            )
        )
        try document.validate()
        return document
    }
}

public enum FigmaImportError: Error, CustomStringConvertible, Equatable {
    case invalidPayload(String)
    case invalidVariable(String)
    case missingValue(variable: String, theme: String)
    case missingMode(collection: String, theme: String)
    case missingAlias(String)
    case aliasCycle(String)
    case typeMismatch(variable: String, expected: String)
    case unsupportedName(String)
    case incompleteComposite(String, fields: [String])
    case nameCollision(first: String, second: String, output: String)

    public var description: String {
        switch self {
        case .invalidPayload(let reason): "Invalid Figma response: \(reason)"
        case .invalidVariable(let id): "Invalid Figma variable: \(id)"
        case .missingValue(let variable, let theme): "Figma variable \(variable) has no value for \(theme)"
        case .missingMode(let collection, let theme): "Figma collection \(collection) has multiple modes but no \(theme) mode"
        case .missingAlias(let id): "Figma alias refers to missing variable \(id)"
        case .aliasCycle(let id): "Figma alias cycle detected at \(id)"
        case .typeMismatch(let variable, let expected): "Figma variable \(variable) is not \(expected)"
        case .unsupportedName(let name): "Unsupported Figma variable name: \(name)"
        case .incompleteComposite(let name, let fields): "Figma composite \(name) is missing: \(fields.sorted().joined(separator: ", "))"
        case .nameCollision(let first, let second, let output): "Figma variables \(first) and \(second) both normalize to \(output)"
        }
    }
}

private final class Resolver {
    let variables: [String: Any]
    let collections: [String: Any]

    init(variables: [String: Any], collections: [String: Any]) {
        self.variables = variables
        self.collections = collections
    }

    func color(id: String, theme: String) throws -> String {
        let raw = try resolve(id: id, theme: theme, stack: [])
        guard
            let value = raw as? [String: Any],
            let red = numeric(value["r"]),
            let green = numeric(value["g"]),
            let blue = numeric(value["b"]),
            let alpha = numeric(value["a"]),
            [red, green, blue, alpha].allSatisfy({ (0...1).contains($0) })
        else {
            throw FigmaImportError.typeMismatch(variable: id, expected: "an RGBA color")
        }
        return String(
            format: "#%02X%02X%02X%02X",
            byte(red), byte(green), byte(blue), byte(alpha)
        )
    }

    func number(id: String, theme: String) throws -> Double {
        let raw = try resolve(id: id, theme: theme, stack: [])
        guard let value = numeric(raw), value.isFinite else {
            throw FigmaImportError.typeMismatch(variable: id, expected: "a finite number")
        }
        return value
    }

    func string(id: String, theme: String) throws -> String {
        let raw = try resolve(id: id, theme: theme, stack: [])
        guard let value = raw as? String else {
            throw FigmaImportError.typeMismatch(variable: id, expected: "a string")
        }
        return value
    }

    func raw(id: String, theme: String) throws -> Any {
        try resolve(id: id, theme: theme, stack: [])
    }

    private func resolve(id: String, theme: String, stack: Set<String>) throws -> Any {
        let marker = "\(id)|\(theme)"
        guard !stack.contains(marker) else { throw FigmaImportError.aliasCycle(id) }
        guard let variable = variables[id] as? [String: Any] else { throw FigmaImportError.missingAlias(id) }
        guard
            let collectionID = variable["variableCollectionId"] as? String,
            let collection = collections[collectionID] as? [String: Any],
            let values = variable["valuesByMode"] as? [String: Any]
        else {
            throw FigmaImportError.invalidVariable(id)
        }

        let modeID = try modeID(for: theme, collectionID: collectionID, collection: collection)
        guard let value = values[modeID] else {
            throw FigmaImportError.missingValue(variable: id, theme: theme)
        }
        if
            let alias = value as? [String: Any],
            alias["type"] as? String == "VARIABLE_ALIAS",
            let targetID = alias["id"] as? String
        {
            var next = stack
            next.insert(marker)
            return try resolve(id: targetID, theme: theme, stack: next)
        }
        return value
    }

    private func modeID(for theme: String, collectionID: String, collection: [String: Any]) throws -> String {
        guard let modes = collection["modes"] as? [[String: Any]], !modes.isEmpty else {
            throw FigmaImportError.invalidVariable(collectionID)
        }
        if let match = modes.first(where: { mode in
            (mode["name"] as? String)?.caseInsensitiveCompare(theme) == .orderedSame
        })?["modeId"] as? String {
            return match
        }
        if modes.count == 1, let defaultModeID = collection["defaultModeId"] as? String {
            return defaultModeID
        }
        throw FigmaImportError.missingMode(
            collection: collection["name"] as? String ?? collectionID,
            theme: theme
        )
    }
}

private struct TypographyBuilder {
    let name: String
    var fontFamily: String?
    var fontSize: Double?
    var fontWeight: Int?
    var lineHeight: Double?
    var letterSpacing: Double?

    func build() throws -> TypographyToken {
        var missing: [String] = []
        if fontFamily == nil { missing.append("fontFamily") }
        if fontSize == nil { missing.append("fontSize") }
        if fontWeight == nil { missing.append("fontWeight") }
        if lineHeight == nil { missing.append("lineHeight") }
        if letterSpacing == nil { missing.append("letterSpacing") }
        guard missing.isEmpty else { throw FigmaImportError.incompleteComposite(name, fields: missing) }
        return TypographyToken(value: TypographyValue(
            fontFamily: fontFamily!,
            fontSize: fontSize!,
            fontWeight: fontWeight!,
            lineHeight: lineHeight!,
            letterSpacing: letterSpacing!
        ))
    }
}

private struct ShadowBuilder {
    let name: String
    var kind: ShadowLayer.Kind = .drop
    var colors: [String: String]?
    var x: Double?
    var y: Double?
    var blur: Double?
    var spread: Double?

    func build() throws -> ShadowLayer {
        var missing: [String] = []
        if colors == nil { missing.append("color") }
        if x == nil { missing.append("x") }
        if y == nil { missing.append("y") }
        if blur == nil { missing.append("blur") }
        if spread == nil { missing.append("spread") }
        guard missing.isEmpty else { throw FigmaImportError.incompleteComposite(name, fields: missing) }
        return ShadowLayer(kind: kind, color: colors!, x: x!, y: y!, blur: blur!, spread: spread!)
    }
}

private func importTypography(
    id: String,
    name: String,
    parts: [String],
    resolver: Resolver,
    builders: inout [String: TypographyBuilder]
) throws {
    guard parts.count >= 3 else { throw FigmaImportError.unsupportedName(name) }
    let path = try tokenPath(parts.dropFirst().dropLast(), source: name)
    let field = categoryName(parts.last!)
    var builder = builders[path] ?? TypographyBuilder(name: path)
    switch field {
    case "fontfamily": builder.fontFamily = try resolver.string(id: id, theme: "light")
    case "fontsize": builder.fontSize = try resolver.number(id: id, theme: "light")
    case "fontweight": builder.fontWeight = try fontWeight(from: resolver.raw(id: id, theme: "light"), variable: id)
    case "lineheight": builder.lineHeight = try resolver.number(id: id, theme: "light")
    case "letterspacing": builder.letterSpacing = try resolver.number(id: id, theme: "light")
    default: throw FigmaImportError.unsupportedName(name)
    }
    builders[path] = builder
}

private func importShadow(
    id: String,
    name: String,
    parts: [String],
    resolver: Resolver,
    builders: inout [String: [Int: ShadowBuilder]]
) throws {
    guard parts.count >= 3 else { throw FigmaImportError.unsupportedName(name) }
    let field = categoryName(parts.last!)
    let possibleIndex = parts.count >= 4 ? Int(parts[parts.count - 2]) : nil
    let index = possibleIndex ?? 0
    let pathParts = possibleIndex == nil ? parts.dropFirst().dropLast() : parts.dropFirst().dropLast(2)
    let path = try tokenPath(pathParts, source: name)
    var indexed = builders[path] ?? [:]
    var builder = indexed[index] ?? ShadowBuilder(name: "\(path)[\(index)]")
    switch field {
    case "kind":
        let raw = try resolver.string(id: id, theme: "light").lowercased()
        guard let kind = ShadowLayer.Kind(rawValue: raw) else { throw FigmaImportError.typeMismatch(variable: id, expected: "drop or inner") }
        builder.kind = kind
    case "color":
        builder.colors = [
            "light": try resolver.color(id: id, theme: "light"),
            "dark": try resolver.color(id: id, theme: "dark"),
        ]
    case "x": builder.x = try resolver.number(id: id, theme: "light")
    case "y": builder.y = try resolver.number(id: id, theme: "light")
    case "blur": builder.blur = try resolver.number(id: id, theme: "light")
    case "spread": builder.spread = try resolver.number(id: id, theme: "light")
    default: throw FigmaImportError.unsupportedName(name)
    }
    indexed[index] = builder
    builders[path] = indexed
}

private func canonicalParts(_ name: String) -> [String] {
    name.split(separator: "/").compactMap { canonicalSegment(String($0)) }
}

private func canonicalImportKey(
    category: String,
    resolvedType: String,
    parts: [String],
    source: String
) throws -> String? {
    switch category {
    case "typography":
        return "typography:\(try tokenPath(parts.dropFirst(), source: source))"
    case "shadow", "shadows":
        guard parts.count >= 3 else { throw FigmaImportError.unsupportedName(source) }
        let field = categoryName(parts.last!)
        let possibleIndex = parts.count >= 4 ? Int(parts[parts.count - 2]) : nil
        let index = possibleIndex ?? 0
        let pathParts = possibleIndex == nil ? parts.dropFirst().dropLast() : parts.dropFirst().dropLast(2)
        let path = try tokenPath(pathParts, source: source)
        return "shadows:\(path).\(index).\(field)"
    case "spacing":
        return "spacing:\(try tokenPath(parts.dropFirst(), source: source))"
    case "cornerradius", "cornerradii", "radius", "radii":
        return "cornerRadii:\(try tokenPath(parts.dropFirst(), source: source))"
    case "borderwidth", "borderwidths":
        return "borderWidths:\(try tokenPath(parts.dropFirst(), source: source))"
    default:
        guard resolvedType == "COLOR" else { return nil }
        let colorParts = ["color", "colors"].contains(category) ? parts.dropFirst() : parts[...]
        return "colors:\(try tokenPath(colorParts, source: source))"
    }
}

private func claim(_ key: String, source: String, importedNames: inout [String: String]) throws {
    if let existing = importedNames[key] {
        throw FigmaImportError.nameCollision(first: existing, second: source, output: key)
    }
    importedNames[key] = source
}

private func canonicalSegment(_ source: String) -> String? {
    let words = source.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    guard let first = words.first else { return nil }
    let head = first.prefix(1).lowercased() + first.dropFirst()
    return ([head] + words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }).joined()
}

private func categoryName(_ value: String) -> String {
    value.lowercased().filter(\.isLetter)
}

private func tokenPath<S: Collection>(_ parts: S, source: String) throws -> String where S.Element == String {
    guard !parts.isEmpty else { throw FigmaImportError.unsupportedName(source) }
    return parts.joined(separator: ".")
}

private func numeric(_ value: Any?) -> Double? {
    guard let number = value as? NSNumber else { return nil }
    guard CFGetTypeID(number) != CFBooleanGetTypeID() else { return nil }
    return number.doubleValue
}

private func byte(_ value: Double) -> UInt8 {
    UInt8((value * 255).rounded())
}

private func fontWeight(from value: Any, variable: String) throws -> Int {
    if let number = numeric(value), number.isFinite, number >= 100, number <= 900 {
        return Int(number.rounded())
    }
    guard let string = value as? String else {
        throw FigmaImportError.typeMismatch(variable: variable, expected: "a numeric or named font weight")
    }
    let weights = [
        "ultralight": 100, "thin": 200, "light": 300, "regular": 400, "normal": 400,
        "medium": 500, "semibold": 600, "bold": 700, "heavy": 800, "black": 900,
    ]
    guard let weight = weights[categoryName(string)] else {
        throw FigmaImportError.typeMismatch(variable: variable, expected: "a supported font weight")
    }
    return weight
}
