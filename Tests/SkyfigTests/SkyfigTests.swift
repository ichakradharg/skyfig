import XCTest
@testable import Skyfig

final class SkyfigTests: XCTestCase {
    func testCommittedGeneratedTokensExposeEveryFamily() {
        XCTAssertEqual(SkyfigTokens.Colors.accent.light, SkyfigRGBAColor(red: 3, green: 105, blue: 161))
        XCTAssertEqual(SkyfigTokens.Colors.Surface.primary.dark.red, 17)
        XCTAssertEqual(SkyfigTokens.Typography.headline.fontWeight, .bold)
        XCTAssertEqual(SkyfigTokens.Spacing.md, 16)
        XCTAssertEqual(SkyfigTokens.CornerRadii.card, 20)
        XCTAssertEqual(SkyfigTokens.BorderWidths.focus, 2)
        XCTAssertEqual(SkyfigTokens.Shadows.card.layers.first?.blur, 18)
    }

    func testSemanticTextTokensMeetAAContrastOnSupportedSurfaces() {
        let themes: [SkyfigTheme] = [.light, .dark]
        let textTokens = [
            SkyfigTokens.Colors.Text.primary,
            SkyfigTokens.Colors.Text.secondary,
        ]
        let surfaceTokens = [
            SkyfigTokens.Colors.Surface.primary,
            SkyfigTokens.Colors.Surface.secondary,
        ]

        for theme in themes {
            for text in textTokens {
                for surface in surfaceTokens {
                    XCTAssertGreaterThanOrEqual(
                        text.value(for: theme).contrastRatio(against: surface.value(for: theme)),
                        4.5,
                        "Expected semantic text to meet WCAG AA contrast in \(theme.rawValue) appearance."
                    )
                }
            }
        }
    }

    func testPrimaryActionContentMeetsAAContrast() {
        for theme in SkyfigTheme.allCases {
            XCTAssertGreaterThanOrEqual(
                SkyfigTokens.Colors.Action.onPrimary.value(for: theme)
                    .contrastRatio(against: SkyfigTokens.Colors.Action.primary.value(for: theme)),
                4.5,
                "Expected primary-action content to meet WCAG AA contrast in \(theme.rawValue) appearance."
            )
        }
    }
}
