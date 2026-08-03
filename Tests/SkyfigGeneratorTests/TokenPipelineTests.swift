import Foundation
import XCTest
@testable import SkyfigGenerator

final class TokenPipelineTests: XCTestCase {
    func testCanonicalDocumentGeneratesEveryTokenFamilyDeterministically() throws {
        let document = makeDocument()
        let first = try SwiftEmitter.generate(document)
        let second = try SwiftEmitter.generate(document)

        XCTAssertEqual(first, second)
        XCTAssertTrue(first.hasSuffix("\n"))
        XCTAssertTrue(first.contains("public enum Surface"))
        XCTAssertTrue(first.contains("public static let primary = SkyfigColorToken"))
        XCTAssertTrue(first.contains("fontWeight: .semibold"))
        XCTAssertTrue(first.contains("public static let md: Double = 16"))
        XCTAssertTrue(first.contains("public static let precise: Double = 0.123456789012345"))
        XCTAssertTrue(first.contains("public enum CornerRadii"))
        XCTAssertTrue(first.contains("public enum BorderWidths"))
        XCTAssertTrue(first.contains("SkyfigShadowToken(layers:"))
        XCTAssertFalse(first.contains(Date().description))
    }

    func testUnknownPropertiesAreRejectedWithAJSONPath() throws {
        let data = Data("""
        {
          "$schema": "schema.json",
          "schemaVersion": "1.0.0",
          "name": "Invalid",
          "defaultTheme": "light",
          "themes": ["light", "dark"],
          "unexpected": true,
          "tokens": {
            "colors": {}, "typography": {}, "spacing": {},
            "cornerRadii": {}, "borderWidths": {}, "shadows": {}
          }
        }
        """.utf8)

        XCTAssertThrowsError(try TokenIO.decode(data)) { error in
            XCTAssertTrue(String(describing: error).contains("$.unexpected: unknown property"))
        }
    }

    func testInvalidThemeAndColorReportDeterministicIssues() throws {
        var document = makeDocument()
        document = TokenDocument(
            name: document.name,
            defaultTheme: "dark",
            themes: ["dark", "light"],
            tokens: TokenCollection(colors: ["accent": ColorToken(values: ["light": "#FFF"])])
        )

        XCTAssertThrowsError(try document.validate()) { error in
            guard let validation = error as? SkyfigValidationError else {
                return XCTFail("Expected SkyfigValidationError")
            }
            XCTAssertEqual(validation.issues, validation.issues.sorted())
            XCTAssertTrue(validation.issues.contains(where: { $0.contains("defaultTheme") }))
            XCTAssertTrue(validation.issues.contains(where: { $0.contains("expected #RRGGBBAA") }))
        }
    }

    func testNamespaceAndTokenCannotCollide() throws {
        let document = TokenDocument(
            name: "Collision",
            tokens: TokenCollection(colors: [
                "surface": ColorToken(values: colors("#FFFFFFFF", "#000000FF")),
                "surface.primary": ColorToken(values: colors("#FFFFFFFF", "#000000FF")),
            ])
        )

        XCTAssertThrowsError(try document.validate()) { error in
            XCTAssertTrue(String(describing: error).contains("cannot be both a token and a namespace"))
        }
    }

    func testCheckModeFailsWithoutChangingStaleOutput() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let output = directory.appendingPathComponent("Tokens.generated.swift")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data("old\n".utf8).write(to: output)

        XCTAssertThrowsError(try SwiftEmitter.write(makeDocument(), to: output, check: true))
        XCTAssertEqual(try String(contentsOf: output, encoding: .utf8), "old\n")
    }

    func testCustomNamespaceIsUsedForGeneratedTokens() throws {
        let generated = try SwiftEmitter.generate(makeDocument(), namespace: "TeamATokens")

        XCTAssertTrue(generated.contains("public enum TeamATokens"))
        XCTAssertFalse(generated.contains("public enum SkyfigTokens"))
    }

    func testInvalidNamespaceIsRejected() throws {
        XCTAssertThrowsError(try SwiftEmitter.generate(makeDocument(), namespace: "team tokens")) { error in
            XCTAssertEqual(error as? GeneratorError, .invalidNamespace("team tokens"))
        }
    }

    func testSwiftStringEscapesAllControlScalars() throws {
        let document = TokenDocument(
            name: "Escaping",
            tokens: TokenCollection(typography: [
                "body": TypographyToken(value: TypographyValue(
                    fontFamily: "Bad\u{0000}Font\u{2028}Name",
                    fontSize: 16,
                    fontWeight: 400,
                    lineHeight: 24,
                    letterSpacing: 0
                )),
            ])
        )

        let generated = try SwiftEmitter.generate(document)
        XCTAssertTrue(generated.contains("Bad\\u{0}Font\\u{2028}Name"))
        XCTAssertFalse(generated.contains("\u{0000}"))
    }

    private func makeDocument() -> TokenDocument {
        TokenDocument(
            name: "Tests",
            tokens: TokenCollection(
                colors: ["surface.primary": ColorToken(values: colors("#FFFFFFFF", "#111827FF"))],
                typography: [
                    "body": TypographyToken(value: TypographyValue(
                        fontFamily: "system",
                        fontSize: 16,
                        fontWeight: 600,
                        lineHeight: 24,
                        letterSpacing: -0.2
                    )),
                ],
                spacing: [
                    "md": DimensionToken(value: 16),
                    "precise": DimensionToken(value: 0.123456789012345),
                ],
                cornerRadii: ["card": DimensionToken(value: 12)],
                borderWidths: ["thin": DimensionToken(value: 1)],
                shadows: [
                    "card": ShadowToken(value: [ShadowLayer(
                        color: colors("#00000020", "#00000080"),
                        x: 0,
                        y: 4,
                        blur: 12,
                        spread: 0
                    )]),
                ]
            )
        )
    }

    private func colors(_ light: String, _ dark: String) -> [String: String] {
        ["light": light, "dark": dark]
    }
}
