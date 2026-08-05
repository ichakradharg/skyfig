import Foundation
@testable import SkyfigGenerator
import XCTest

final class FigmaImporterTests: XCTestCase {
    func testImportsModesAliasesAndCompositeTokens() throws {
        let url = try XCTUnwrap(Bundle.module.url(
            forResource: "figma-variables",
            withExtension: "json",
            subdirectory: "Fixtures"
        ))
        let document = try FigmaImporter.importVariables(from: Data(contentsOf: url), name: "Fixture")

        XCTAssertEqual(document.tokens.colors["accent"]?.values["light"], "#0066FFFF")
        XCTAssertEqual(document.tokens.colors["brand"]?.values["dark"], "#66A3FFFF")
        XCTAssertEqual(document.tokens.spacing["md"]?.value, 16)
        XCTAssertEqual(document.tokens.typography["body"]?.value.fontWeight, 600)
        XCTAssertEqual(document.tokens.shadows["card"]?.value.first?.blur, 12)
        XCTAssertEqual(document.tokens.shadows["card"]?.value.first?.color["dark"], "#00000066")
    }

    func testRejectsNamesThatNormalizeToTheSameToken() throws {
        let data = Data("""
        {
          "meta": {
            "variableCollections": {
              "c": {
                "defaultModeId": "light",
                "modes": [{"modeId": "light", "name": "Light"}]
              }
            },
            "variables": {
              "a": {
                "name": "colors/brand blue",
                "resolvedType": "COLOR",
                "variableCollectionId": "c",
                "valuesByMode": {"light": {"r": 0, "g": 0, "b": 1, "a": 1}}
              },
              "b": {
                "name": "colors/brand-blue",
                "resolvedType": "COLOR",
                "variableCollectionId": "c",
                "valuesByMode": {"light": {"r": 0, "g": 0, "b": 1, "a": 1}}
              }
            }
          }
        }
        """.utf8)

        XCTAssertThrowsError(try FigmaImporter.importVariables(from: data)) { error in
            XCTAssertTrue(String(describing: error).contains("both normalize to colors:brandBlue"))
        }
    }

    func testRejectsImplicitAndExplicitShadowLayerZero() throws {
        let data = Data("""
        {
          "meta": {
            "variableCollections": {
              "c": {
                "defaultModeId": "light",
                "modes": [{"modeId": "light", "name": "Light"}]
              }
            },
            "variables": {
              "a": {
                "name": "shadows/card/x",
                "resolvedType": "FLOAT",
                "variableCollectionId": "c",
                "valuesByMode": {"light": 2}
              },
              "b": {
                "name": "shadows/card/0/x",
                "resolvedType": "FLOAT",
                "variableCollectionId": "c",
                "valuesByMode": {"light": 4}
              }
            }
          }
        }
        """.utf8)

        XCTAssertThrowsError(try FigmaImporter.importVariables(from: data)) { error in
            XCTAssertTrue(String(describing: error).contains("both normalize to shadows:card.0.x"))
        }
    }

    func testSkipsDeletedButReferencedVariables() throws {
        let data = Data("""
        {
          "meta": {
            "variableCollections": {
              "c": {
                "defaultModeId": "mode",
                "modes": [{"modeId": "mode", "name": "Only"}]
              }
            },
            "variables": {
              "deleted": {
                "name": "colors/old",
                "deletedButReferenced": true,
                "resolvedType": "COLOR",
                "variableCollectionId": "c",
                "valuesByMode": {"mode": {"r": 1, "g": 0, "b": 0, "a": 1}}
              }
            }
          }
        }
        """.utf8)

        let document = try FigmaImporter.importVariables(from: data)
        XCTAssertTrue(document.tokens.colors.isEmpty)
    }

    func testMultiModeCollectionRequiresExplicitDarkMode() throws {
        let data = Data("""
        {
          "meta": {
            "variableCollections": {
              "c": {
                "name": "Theme",
                "defaultModeId": "light",
                "modes": [
                  {"modeId": "light", "name": "Light"},
                  {"modeId": "typo", "name": "Drak"}
                ]
              }
            },
            "variables": {
              "accent": {
                "name": "colors/accent",
                "resolvedType": "COLOR",
                "variableCollectionId": "c",
                "valuesByMode": {
                  "light": {"r": 0, "g": 0, "b": 1, "a": 1},
                  "typo": {"r": 1, "g": 0, "b": 0, "a": 1}
                }
              }
            }
          }
        }
        """.utf8)

        XCTAssertThrowsError(try FigmaImporter.importVariables(from: data)) { error in
            XCTAssertTrue(String(describing: error).contains("multiple modes but no dark mode"))
        }
    }

    func testPreservesArbitraryHierarchyWithoutFamilyMapping() throws {
        let data = Data("""
        {"meta":{"variableCollections":{"c":{"defaultModeId":"l","modes":[
        {"modeId":"l","name":"Light"},{"modeId":"d","name":"Dark"}
        ]}},"variables":{
        "color":{"name":"foundation/colors/brand/primary","resolvedType":"COLOR",
        "variableCollectionId":"c","valuesByMode":{"l":{"r":0,"g":0.4,"b":1,"a":1},
        "d":{"r":0.3,"g":0.6,"b":1,"a":1}}},
        "number":{"name":"layout/Grid Size/2xl","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"l":32,"d":36}}
        }}}
        """.utf8)
        let document = try FigmaImporter.importVariables(from: data)
        XCTAssertEqual(document.tokens.dynamic.colors["foundation.colors.brand.primary"]?.values["dark"], "#4D99FFFF")
        XCTAssertEqual(document.tokens.dynamic.numbers["layout.gridSize._2xl"]?.values["light"], 32)
        let generated = try SwiftEmitter.generate(document, namespace: "TeamTokens")
        XCTAssertTrue(generated.contains("public enum Foundation"))
        XCTAssertTrue(generated.contains("public enum Brand"))
        XCTAssertTrue(generated.contains("public static let primary = SkyfigColorToken"))
        XCTAssertTrue(generated.contains("public enum GridSize"))
        XCTAssertTrue(generated.contains("public static let _2xl"))
    }

    func testInfersAppleHIGTypographyAcrossArbitraryStructures() throws {
        let document = try importFixture("figma-apple-hig-typography")

        XCTAssertEqual(document.tokens.typography.count, 11)
        XCTAssertEqual(document.tokens.typography["foundation.type.largeTitle"]?.value.fontSize, 34)
        XCTAssertEqual(document.tokens.typography["semantic.text.title1"]?.value.lineHeight, 34)
        XCTAssertEqual(document.tokens.typography["semantic.text.headline"]?.value.fontWeight, 600)
        XCTAssertEqual(document.tokens.typography["media.caption.secondary"]?.value.fontSize, 11)

        let generated = try SwiftEmitter.generate(document, namespace: "TeamTokens")
        XCTAssertTrue(generated.contains("public enum Typography"))
        XCTAssertTrue(generated.contains("public enum Foundation"))
        XCTAssertTrue(generated.contains("public static let largeTitle = SkyfigTypographyToken"))
        XCTAssertTrue(generated.contains("public static let secondary = SkyfigTypographyToken"))
    }

    func testInfersSingleAndOrderedMultiLayerShadows() throws {
        let document = try importFixture("figma-shadow-structures")

        XCTAssertEqual(document.tokens.shadows.count, 3)
        XCTAssertEqual(document.tokens.shadows["effects.modal"]?.value.first?.blur, 32)
        XCTAssertEqual(document.tokens.shadows["effects.modal"]?.value.first?.spread, 0)
        XCTAssertEqual(document.tokens.shadows["elevation.floatingPanel"]?.value.count, 2)
        XCTAssertEqual(document.tokens.shadows["elevation.floatingPanel"]?.value[1].spread, -2)
        XCTAssertEqual(document.tokens.shadows["components.search.field.shadow"]?.value.first?.kind, .inner)
        XCTAssertNil(document.tokens.shadows["effects.incomplete"])
        XCTAssertNotNil(document.tokens.dynamic.colors["effects.incomplete.color"])
        XCTAssertNotNil(document.tokens.dynamic.numbers["effects.incomplete.blur"])
    }

    func testInfersCompositesAtArbitraryHierarchyDepth() throws {
        let document = try importFixture("figma-deeply-nested-composites")
        let typographyPath = "enterprise.retail.ios.components.profile.header.primaryTitle"
        let shadowPath = "enterprise.retail.ios.components.profile.card.elevation"

        XCTAssertEqual(document.tokens.typography[typographyPath]?.value.fontWeight, 700)
        XCTAssertEqual(document.tokens.typography[typographyPath]?.value.letterSpacing, -0.2)
        XCTAssertEqual(document.tokens.shadows[shadowPath]?.value.first?.blur, 16)

        let generated = try SwiftEmitter.generate(document, namespace: "RetailTokens")
        XCTAssertTrue(generated.contains("public enum Enterprise"))
        XCTAssertTrue(generated.contains("public enum PrimaryTitle"))
        XCTAssertTrue(generated.contains("public static let elevation = SkyfigShadowToken"))
    }

    func testAmbiguousTypographyAliasesRemainPrimitive() throws {
        let data = Data("""
        {"meta":{"variableCollections":{"c":{"defaultModeId":"v","modes":[
        {"modeId":"v","name":"Value"}
        ]}},"variables":{
        "family":{"name":"content/card/type/family","resolvedType":"STRING",
        "variableCollectionId":"c","valuesByMode":{"v":"system"}},
        "size":{"name":"content/card/type/size","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"v":16}},
        "fontSize":{"name":"content/card/type/font-size","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"v":17}},
        "weight":{"name":"content/card/type/weight","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"v":400}},
        "leading":{"name":"content/card/type/leading","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"v":22}},
        "tracking":{"name":"content/card/type/tracking","resolvedType":"FLOAT",
        "variableCollectionId":"c","valuesByMode":{"v":0}}
        }}}
        """.utf8)

        let document = try FigmaImporter.importVariables(from: data)
        XCTAssertNil(document.tokens.typography["content.card.type"])
        XCTAssertNotNil(document.tokens.dynamic.numbers["content.card.type.size"])
        XCTAssertNotNil(document.tokens.dynamic.numbers["content.card.type.fontSize"])
    }

    private func importFixture(_ name: String) throws -> TokenDocument {
        let url = try XCTUnwrap(Bundle.module.url(
            forResource: name,
            withExtension: "json",
            subdirectory: "Fixtures"
        ))
        return try FigmaImporter.importVariables(from: Data(contentsOf: url), name: name)
    }
}
