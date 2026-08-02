import Foundation

public struct TokenDocument: Codable, Equatable, Sendable {
    public let schemaURL: String
    public let schemaVersion: String
    public let name: String
    public let defaultTheme: String
    public let themes: [String]
    public let tokens: TokenCollection

    public init(
        schemaURL: String = "../Schema/skyfig.tokens.schema.json",
        schemaVersion: String = "1.0.0",
        name: String,
        defaultTheme: String = "light",
        themes: [String] = ["light", "dark"],
        tokens: TokenCollection
    ) {
        self.schemaURL = schemaURL
        self.schemaVersion = schemaVersion
        self.name = name
        self.defaultTheme = defaultTheme
        self.themes = themes
        self.tokens = tokens
    }

    enum CodingKeys: String, CodingKey {
        case schemaURL = "$schema"
        case schemaVersion
        case name
        case defaultTheme
        case themes
        case tokens
    }
}

public struct TokenCollection: Codable, Equatable, Sendable {
    public let colors: [String: ColorToken]
    public let typography: [String: TypographyToken]
    public let spacing: [String: DimensionToken]
    public let cornerRadii: [String: DimensionToken]
    public let borderWidths: [String: DimensionToken]
    public let shadows: [String: ShadowToken]

    public init(
        colors: [String: ColorToken] = [:],
        typography: [String: TypographyToken] = [:],
        spacing: [String: DimensionToken] = [:],
        cornerRadii: [String: DimensionToken] = [:],
        borderWidths: [String: DimensionToken] = [:],
        shadows: [String: ShadowToken] = [:]
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.cornerRadii = cornerRadii
        self.borderWidths = borderWidths
        self.shadows = shadows
    }
}

public struct ColorToken: Codable, Equatable, Sendable {
    public let description: String?
    public let values: [String: String]

    public init(description: String? = nil, values: [String: String]) {
        self.description = description
        self.values = values
    }
}

public struct DimensionToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: Double

    public init(description: String? = nil, value: Double) {
        self.description = description
        self.value = value
    }
}

public struct TypographyToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: TypographyValue

    public init(description: String? = nil, value: TypographyValue) {
        self.description = description
        self.value = value
    }
}

public struct TypographyValue: Codable, Equatable, Sendable {
    public let fontFamily: String
    public let fontSize: Double
    public let fontWeight: Int
    public let lineHeight: Double
    public let letterSpacing: Double

    public init(
        fontFamily: String,
        fontSize: Double,
        fontWeight: Int,
        lineHeight: Double,
        letterSpacing: Double
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

public struct ShadowToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: [ShadowLayer]

    public init(description: String? = nil, value: [ShadowLayer]) {
        self.description = description
        self.value = value
    }
}

public struct ShadowLayer: Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Equatable, Sendable {
        case drop
        case inner
    }

    public let kind: Kind
    public let color: [String: String]
    public let x: Double
    public let y: Double
    public let blur: Double
    public let spread: Double

    public init(
        kind: Kind = .drop,
        color: [String: String],
        x: Double,
        y: Double,
        blur: Double,
        spread: Double
    ) {
        self.kind = kind
        self.color = color
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
    }
}
