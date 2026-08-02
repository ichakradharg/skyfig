#if canImport(SwiftUI)
import SwiftUI

public extension SkyfigRGBAColor {
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
    func color(for colorScheme: ColorScheme) -> Color {
        value(for: colorScheme == .dark ? .dark : .light).color
    }
}

public extension SkyfigTypographyToken {
    var font: Font {
        if fontFamily.caseInsensitiveCompare("system") == .orderedSame {
            return .system(size: fontSize, weight: fontWeight.swiftUIWeight)
        }
        return .custom(fontFamily, size: fontSize).weight(fontWeight.swiftUIWeight)
    }

    var lineSpacing: Double {
        max(0, lineHeight - fontSize)
    }
}

public extension SkyfigFontWeight {
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
