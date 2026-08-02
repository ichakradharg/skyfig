import Foundation

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

public struct SkyfigColorToken: Equatable, Hashable, Sendable {
    public let light: SkyfigRGBAColor
    public let dark: SkyfigRGBAColor

    public init(light: SkyfigRGBAColor, dark: SkyfigRGBAColor) {
        self.light = light
        self.dark = dark
    }

    public func value(for theme: SkyfigTheme) -> SkyfigRGBAColor {
        switch theme {
        case .light: light
        case .dark: dark
        }
    }
}

public enum SkyfigTheme: String, CaseIterable, Sendable {
    case light
    case dark
}

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

public struct SkyfigShadowLayer: Equatable, Sendable {
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

public struct SkyfigShadowToken: Equatable, Sendable {
    public let layers: [SkyfigShadowLayer]

    public init(layers: [SkyfigShadowLayer]) {
        self.layers = layers
    }
}
