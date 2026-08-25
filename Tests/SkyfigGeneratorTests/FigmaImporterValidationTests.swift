import Foundation
@testable import SkyfigGenerator
import XCTest

final class FigmaImporterValidationTests: XCTestCase {
    func testDynamicPrimitiveRequiresAnExplicitDarkMode() throws {
        let data = Data("""
        {
          "meta": {
            "variableCollections": {
              "c": {
                "name": "Theme",
                "defaultModeId": "light",
                "modes": [
                  {"modeId": "light", "name": "Light"},
                  {"modeId": "alternate", "name": "Alternate"}
                ]
              }
            },
            "variables": {
              "gutter": {
                "name": "layout/gutter",
                "resolvedType": "FLOAT",
                "variableCollectionId": "c",
                "valuesByMode": {"light": 16, "alternate": 20}
              }
            }
          }
        }
        """.utf8)

        XCTAssertThrowsError(try FigmaImporter.importVariables(from: data)) { error in
            XCTAssertEqual(error as? FigmaImportError, .missingMode(collection: "Theme", theme: "dark"))
        }
    }
}
