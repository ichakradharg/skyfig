#if canImport(SwiftUI)
import SwiftUI

public extension SkyfigRGBAColor {
    /// Converts this sRGB value into a SwiftUI color.
    var color: Color {
        Color(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

public extension SkyfigColorToken {
    /// Resolves this token for a SwiftUI color scheme.
    func color(for colorScheme: ColorScheme) -> Color {
        value(for: colorScheme == .dark ? .dark : .light).color
    }
}

public extension SkyfigTypographyToken {
    /// Converts this token into a SwiftUI font.
    var font: Font {
        if fontFamily.caseInsensitiveCompare("system") == .orderedSame {
            return .system(size: fontSize, weight: fontWeight.swiftUIWeight)
        }
        return .custom(fontFamily, size: fontSize).weight(fontWeight.swiftUIWeight)
    }

    /// Converts this token into a Dynamic Type-aware SwiftUI font.
    ///
    /// Use this overload in app UI and select the text style that matches the
    /// semantic role of the token. The ``font`` property remains available for
    /// fixed-size or layout-preview use cases.
    func font(relativeTo textStyle: Font.TextStyle) -> Font {
        if fontFamily.caseInsensitiveCompare("system") == .orderedSame {
            return .system(textStyle, design: .default, weight: fontWeight.swiftUIWeight)
        }
        return .custom(fontFamily, size: fontSize, relativeTo: textStyle)
            .weight(fontWeight.swiftUIWeight)
    }

    /// The additional SwiftUI line spacing implied by the token's line height.
    var lineSpacing: Double {
        max(0, lineHeight - fontSize)
    }
}

public extension SkyfigFontWeight {
    /// Converts this token weight into the matching SwiftUI font weight.
    var swiftUIWeight: Font.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}
#endif
