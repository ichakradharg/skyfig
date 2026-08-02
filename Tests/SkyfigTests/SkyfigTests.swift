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
}
