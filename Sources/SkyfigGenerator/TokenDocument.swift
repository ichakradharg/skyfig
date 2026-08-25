import Foundation

/// The canonical, schema-backed token document consumed by the generator.
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

/// The supported token families in a canonical token document.
public struct TokenCollection: Codable, Equatable, Sendable {
    public let colors: [String: ColorToken]
    public let typography: [String: TypographyToken]
    public let spacing: [String: DimensionToken]
    public let cornerRadii: [String: DimensionToken]
    public let borderWidths: [String: DimensionToken]
    public let shadows: [String: ShadowToken]
    public let metrics: [String: DimensionToken]
    public let opacities: [String: OpacityToken]
    public let materials: [String: MaterialToken]
    public let symbols: [String: SymbolToken]
    public let motion: [String: MotionToken]
    /// Primitive Figma variables preserved by their source hierarchy. These are emitted at the namespace root.
    public let dynamic: DynamicTokenCollection

    public init(
        colors: [String: ColorToken] = [:],
        typography: [String: TypographyToken] = [:],
        spacing: [String: DimensionToken] = [:],
        cornerRadii: [String: DimensionToken] = [:],
        borderWidths: [String: DimensionToken] = [:],
        shadows: [String: ShadowToken] = [:],
        metrics: [String: DimensionToken] = [:],
        opacities: [String: OpacityToken] = [:],
        materials: [String: MaterialToken] = [:],
        symbols: [String: SymbolToken] = [:],
        motion: [String: MotionToken] = [:],
        dynamic: DynamicTokenCollection = DynamicTokenCollection()
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.cornerRadii = cornerRadii
        self.borderWidths = borderWidths
        self.shadows = shadows
        self.metrics = metrics
        self.opacities = opacities
        self.materials = materials
        self.symbols = symbols
        self.motion = motion
        self.dynamic = dynamic
    }

    enum CodingKeys: String, CodingKey {
        case colors, typography, spacing, cornerRadii, borderWidths, shadows
        case metrics, opacities, materials, symbols, motion, dynamic
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        colors = try container.decode([String: ColorToken].self, forKey: .colors)
        typography = try container.decode([String: TypographyToken].self, forKey: .typography)
        spacing = try container.decode([String: DimensionToken].self, forKey: .spacing)
        cornerRadii = try container.decode([String: DimensionToken].self, forKey: .cornerRadii)
        borderWidths = try container.decode([String: DimensionToken].self, forKey: .borderWidths)
        shadows = try container.decode([String: ShadowToken].self, forKey: .shadows)
        metrics = try container.decodeIfPresent([String: DimensionToken].self, forKey: .metrics) ?? [:]
        opacities = try container.decodeIfPresent([String: OpacityToken].self, forKey: .opacities) ?? [:]
        materials = try container.decodeIfPresent([String: MaterialToken].self, forKey: .materials) ?? [:]
        symbols = try container.decodeIfPresent([String: SymbolToken].self, forKey: .symbols) ?? [:]
        motion = try container.decodeIfPresent([String: MotionToken].self, forKey: .motion) ?? [:]
        dynamic = try container.decodeIfPresent(
            DynamicTokenCollection.self,
            forKey: .dynamic
        ) ?? DynamicTokenCollection()
    }
}

public struct OpacityToken: Codable, Equatable, Sendable {
    public let value: Double

    public init(value: Double) {
        self.value = value
    }
}

public struct MaterialToken: Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case ultraThin, thin, regular, thick
    }

    public let value: Kind

    public init(value: Kind) {
        self.value = value
    }
}

public struct SymbolToken: Codable, Equatable, Sendable {
    public enum Scale: String, Codable, Sendable {
        case small, medium, large
    }

    public enum RenderingMode: String, Codable, Sendable {
        case monochrome, hierarchical, palette, multicolor
    }

    public let name: String
    public let weight: Int
    public let scale: Scale
    public let renderingMode: RenderingMode
    public let tint: String
    public let availability: String?

    public init(
        name: String,
        weight: Int = 400,
        scale: Scale = .medium,
        renderingMode: RenderingMode = .monochrome,
        tint: String,
        availability: String? = nil
    ) {
        self.name = name
        self.weight = weight
        self.scale = scale
        self.renderingMode = renderingMode
        self.tint = tint
        self.availability = availability
    }
}

public struct MotionToken: Codable, Equatable, Sendable {
    public enum Curve: String, Codable, Sendable {
        case easeInOut, easeIn, easeOut, linear
    }

    public let duration: Double
    public let curve: Curve
    public let reduceMotionDuration: Double

    public init(duration: Double, curve: Curve, reduceMotionDuration: Double = 0) {
        self.duration = duration
        self.curve = curve
        self.reduceMotionDuration = reduceMotionDuration
    }
}

/// Structure-driven primitive tokens imported from arbitrary Figma variable paths.
public struct DynamicTokenCollection: Codable, Equatable, Sendable {
    public let colors: [String: ColorToken]
    public let numbers: [String: ThemedValueToken<Double>]
    public let strings: [String: ThemedValueToken<String>]
    public let booleans: [String: ThemedValueToken<Bool>]

    public init(
        colors: [String: ColorToken] = [:],
        numbers: [String: ThemedValueToken<Double>] = [:],
        strings: [String: ThemedValueToken<String>] = [:],
        booleans: [String: ThemedValueToken<Bool>] = [:]
    ) {
        self.colors = colors
        self.numbers = numbers
        self.strings = strings
        self.booleans = booleans
    }
}

public struct ThemedValueToken<Value: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    public let description: String?
    public let values: [String: Value]
    public init(description: String? = nil, values: [String: Value]) {
        self.description = description
        self.values = values
    }
}

/// A color token with canonical light and dark color values.
public struct ColorToken: Codable, Equatable, Sendable {
    public let description: String?
    public let values: [String: String]

    public init(description: String? = nil, values: [String: String]) {
        self.description = description
        self.values = values
    }
}

/// A single dimension token measured in points.
public struct DimensionToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: Double

    public init(description: String? = nil, value: Double) {
        self.description = description
        self.value = value
    }
}

/// A typography token and its component value.
public struct TypographyToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: TypographyValue

    public init(description: String? = nil, value: TypographyValue) {
        self.description = description
        self.value = value
    }
}

/// The font metrics stored by a typography token.
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

/// A shadow token containing ordered shadow layers.
public struct ShadowToken: Codable, Equatable, Sendable {
    public let description: String?
    public let value: [ShadowLayer]

    public init(description: String? = nil, value: [ShadowLayer]) {
        self.description = description
        self.value = value
    }
}

/// The canonical representation of one shadow layer.
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
