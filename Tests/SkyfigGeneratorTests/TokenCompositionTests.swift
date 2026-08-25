import Foundation
@testable import SkyfigGenerator
import XCTest

final class TokenCompositionTests: XCTestCase {
    func testPartialDocumentDecodesMissingFamiliesAsEmptyMaps() throws {
        let data = Data("""
        {
          "$schema": "schema.json",
          "schemaVersion": "1.0.0",
          "name": "Shared primitives",
          "defaultTheme": "light",
          "themes": ["light", "dark"],
          "tokens": {
            "spacing": { "content.gutter": { "value": 20 } },
            "dynamic": {
              "booleans": {
                "accessibility.prefersBorders": {
                  "values": { "light": false, "dark": true }
                }
              }
            }
          }
        }
        """.utf8)

        let document = try TokenIO.decode(data)

        XCTAssertEqual(document.tokens.spacing["content.gutter"]?.value, 20)
        XCTAssertEqual(
            document.tokens.dynamic.booleans["accessibility.prefersBorders"]?.values["dark"],
            true
        )
        XCTAssertTrue(document.tokens.colors.isEmpty)
        XCTAssertTrue(document.tokens.dynamic.colors.isEmpty)
    }

    func testMultipleDocumentsMergeIntoOneSwiftReadyAPI() throws {
        let foundation = TokenDocument(
            name: "Foundation",
            tokens: TokenCollection(colors: [
                "brand.primary": ColorToken(values: colors("#0369A1FF", "#38BDF8FF")),
            ])
        )
        let layout = TokenDocument(
            name: "Layout",
            tokens: TokenCollection(spacing: ["content.gutter": DimensionToken(value: 20)])
        )

        let merged = try TokenIO.merge([foundation, layout])
        let generated = try SwiftEmitter.generate(merged)

        XCTAssertEqual(merged.name, "Foundation + Layout")
        XCTAssertNotNil(merged.tokens.colors["brand.primary"])
        XCTAssertEqual(merged.tokens.spacing["content.gutter"]?.value, 20)
        XCTAssertTrue(generated.contains("public enum Brand"))
        XCTAssertTrue(generated.contains("public static let primary = SkyfigColorToken"))
        XCTAssertTrue(generated.contains("public static let gutter: Double = 20"))
    }

    func testPackagedSharedFixturesMergeIntoGeneratedAPI() throws {
        let colorsURL = try fixtureURL(named: "shared-colors.tokens")
        let layoutURL = try fixtureURL(named: "shared-layout.tokens")

        let merged = try TokenIO.load(from: [colorsURL, layoutURL])
        let generated = try SwiftEmitter.generate(merged)

        XCTAssertNotNil(merged.tokens.colors["shared.accent"])
        XCTAssertEqual(merged.tokens.spacing["shared.gutter"]?.value, 24)
        XCTAssertTrue(generated.contains("public enum Shared"))
        XCTAssertTrue(generated.contains("public static let gutter: Double = 24"))
    }

    func testDuplicateTokenPathsAcrossDocumentsAreRejected() throws {
        let foundation = TokenDocument(
            name: "Foundation",
            tokens: TokenCollection(colors: [
                "brand.primary": ColorToken(values: colors("#0369A1FF", "#38BDF8FF")),
            ])
        )
        let product = TokenDocument(
            name: "Product",
            tokens: TokenCollection(colors: [
                "brand.primary": ColorToken(values: colors("#0284C7FF", "#7DD3FCFF")),
            ])
        )

        XCTAssertThrowsError(try TokenIO.merge([foundation, product])) { error in
            guard let mergeError = error as? TokenMergeError else {
                return XCTFail("Expected TokenMergeError")
            }
            XCTAssertEqual(
                mergeError.issues,
                ["$.tokens.colors.brand.primary: declared in both Foundation and Product"]
            )
        }
    }

    func testCrossDocumentNamespaceCollisionsAreRejected() throws {
        let foundation = TokenDocument(
            name: "Foundation",
            tokens: TokenCollection(colors: [
                "brand": ColorToken(values: colors("#0369A1FF", "#38BDF8FF")),
            ])
        )
        let product = TokenDocument(
            name: "Product",
            tokens: TokenCollection(colors: [
                "brand.primary": ColorToken(values: colors("#0284C7FF", "#7DD3FCFF")),
            ])
        )

        XCTAssertThrowsError(try TokenIO.merge([foundation, product])) { error in
            guard let validationError = error as? SkyfigValidationError else {
                return XCTFail("Expected SkyfigValidationError")
            }
            XCTAssertEqual(
                validationError.issues,
                ["$.tokens.colors: brand cannot be both a token and a namespace"]
            )
        }
    }

    func testDocumentsWithIncompatibleMetadataAreRejected() throws {
        let foundation = TokenDocument(name: "Foundation", tokens: TokenCollection())
        let unsupported = TokenDocument(
            schemaVersion: "2.0.0",
            name: "Unsupported",
            tokens: TokenCollection()
        )

        XCTAssertThrowsError(try TokenIO.merge([foundation, unsupported])) { error in
            guard let validationError = error as? SkyfigValidationError else {
                return XCTFail("Expected SkyfigValidationError")
            }
            XCTAssertEqual(
                validationError.issues,
                ["$.schemaVersion: expected supported version 1.0.0"]
            )
        }
    }

    func testMergingNoDocumentsIsRejected() {
        XCTAssertThrowsError(try TokenIO.merge([])) { error in
            XCTAssertEqual(
                error as? TokenMergeError,
                TokenMergeError(issues: ["$: at least one token document is required"])
            )
        }
    }

    private func fixtureURL(named name: String) throws -> URL {
        try XCTUnwrap(Bundle.module.url(
            forResource: name,
            withExtension: "json",
            subdirectory: "Fixtures"
        ))
    }

    private func colors(_ light: String, _ dark: String) -> [String: String] {
        ["light": light, "dark": dark]
    }
}
