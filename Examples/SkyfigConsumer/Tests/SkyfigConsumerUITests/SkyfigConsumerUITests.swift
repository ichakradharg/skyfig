import XCTest

@MainActor
final class SkyfigConsumerUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        XCTAssertTrue(app.staticTexts["Design system preview"].waitForExistence(timeout: 5))
    }

    func testFiveTabsAreAvailable() {
        for title in ["Home", "Library", "Activity", "Profile", "Search"] {
            XCTAssertTrue(navigationItem(named: title).waitForExistence(timeout: 5))
        }
    }

    func testEveryTabPresentsItsTokenDrivenContent() {
        let expectations = [
            (tab: "Home", content: "Design system preview"),
            (tab: "Library", content: "Library"),
            (tab: "Activity", content: "Activity"),
            (tab: "Profile", content: "Profile"),
            (tab: "Search", content: "Search"),
        ]

        for expectation in expectations {
            navigationItem(named: expectation.tab).tap()
            XCTAssertTrue(app.staticTexts[expectation.content].waitForExistence(timeout: 5))
        }
    }

    func testHomeRemainsUsableAtAnAccessibilityTextSize() {
        app.terminate()
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Design system preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Explore tokens"].exists)
        XCTAssertTrue(app.buttons["Add item"].exists)
        XCTAssertTrue(typographySample(named: "Large Title").exists)
    }

    func testEveryAppleTextStyleIsShowcasedAcrossTheTabs() {
        let expectations = [
            (tab: "Home", styles: ["Large Title", "Title 1"]),
            (tab: "Library", styles: ["Title 2", "Title 3", "Headline"]),
            (tab: "Activity", styles: ["Body", "Callout"]),
            (tab: "Profile", styles: ["Subheadline", "Footnote"]),
            (tab: "Search", styles: ["Caption 1", "Caption 2"]),
        ]

        for expectation in expectations {
            navigationItem(named: expectation.tab).tap()
            for style in expectation.styles {
                XCTAssertTrue(
                    typographySample(named: style).waitForExistence(timeout: 5),
                    "Missing \(style) on the \(expectation.tab) tab"
                )
            }
        }
    }

    func testEveryInferredShadowStructureIsShowcased() {
        for name in ["Modal", "Floating panel", "Search field"] {
            let shadow = app.descendants(matching: .any)["Shadow.\(name)"]
            var scrollAttempts = 0
            while !shadow.exists && scrollAttempts < 5 {
                app.swipeUp()
                scrollAttempts += 1
            }
            XCTAssertTrue(
                shadow.waitForExistence(timeout: 5),
                "Missing the \(name) shadow example"
            )
        }
    }

    private func navigationItem(named title: String) -> XCUIElement {
        let button = app.buttons[title].firstMatch
        if button.exists {
            return button
        }

        let cell = app.cells[title].firstMatch
        return cell.exists ? cell : app.descendants(matching: .any)[title].firstMatch
    }

    private func typographySample(named name: String) -> XCUIElement {
        app.descendants(matching: .any)["Typography.\(name)"]
    }
}
