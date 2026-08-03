import Foundation
import XCTest
@testable import SkyfigGenerator

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
        {"meta":{"variableCollections":{"c":{"defaultModeId":"l","modes":[{"modeId":"l","name":"Light"},{"modeId":"d","name":"Dark"}]}},"variables":{
        "color":{"name":"foundation/colors/brand/primary","resolvedType":"COLOR","variableCollectionId":"c","valuesByMode":{"l":{"r":0,"g":0.4,"b":1,"a":1},"d":{"r":0.3,"g":0.6,"b":1,"a":1}}},
        "number":{"name":"layout/Grid Size/2xl","resolvedType":"FLOAT","variableCollectionId":"c","valuesByMode":{"l":32,"d":36}}
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
}
