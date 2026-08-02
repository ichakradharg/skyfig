import Foundation

/// An sRGB color stored as four 8-bit red, green, blue, and alpha components.
///
/// Use the SwiftUI `color` property when SwiftUI is available.
public struct SkyfigRGBAColor: Equatable, Hashable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

/// A color token with a value for each supported appearance theme.
public struct SkyfigColorToken: Equatable, Hashable, Sendable {
    public let light: SkyfigRGBAColor
    public let dark: SkyfigRGBAColor

    public init(light: SkyfigRGBAColor, dark: SkyfigRGBAColor) {
        self.light = light
        self.dark = dark
    }

    /// Returns the color value for the requested theme.
    public func value(for theme: SkyfigTheme) -> SkyfigRGBAColor {
        switch theme {
        case .light: light
        case .dark: dark
        }
    }
}

/// The appearance themes supported by version 1 token documents.
public enum SkyfigTheme: String, CaseIterable, Sendable {
    case light
    case dark
}

/// A CSS-style numeric font weight used by generated typography tokens.
public enum SkyfigFontWeight: Int, CaseIterable, Sendable {
    case ultraLight = 100
    case thin = 200
    case light = 300
    case regular = 400
    case medium = 500
    case semibold = 600
    case bold = 700
    case heavy = 800
    case black = 900
}

/// A platform-neutral typography definition generated from a token document.
public struct SkyfigTypographyToken: Equatable, Sendable {
    public let fontFamily: String
    public let fontSize: Double
    public let fontWeight: SkyfigFontWeight
    public let lineHeight: Double
    public let letterSpacing: Double

    public init(
        fontFamily: String,
        fontSize: Double,
        fontWeight: SkyfigFontWeight,
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

/// One layer in a tokenized shadow, expressed in points.
public struct SkyfigShadowLayer: Equatable, Sendable {
    /// The visual placement of a shadow layer.
    public enum Kind: String, Sendable {
        case drop
        case inner
    }

    public let kind: Kind
    public let color: SkyfigColorToken
    public let x: Double
    public let y: Double
    public let blur: Double
    public let spread: Double

    public init(
        kind: Kind,
        color: SkyfigColorToken,
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

/// A tokenized shadow composed of one or more ordered layers.
public struct SkyfigShadowToken: Equatable, Sendable {
    public let layers: [SkyfigShadowLayer]

    public init(layers: [SkyfigShadowLayer]) {
        self.layers = layers
    }
}
