import XCTest

@MainActor
final class SkyfigConsumerUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testFiveTabsAreAvailable() {
        for title in ["Home", "Library", "Activity", "Profile", "Search"] {
            XCTAssertTrue(app.tabBars.buttons[title].waitForExistence(timeout: 5))
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
            app.tabBars.buttons[expectation.tab].tap()
            XCTAssertTrue(app.staticTexts[expectation.content].waitForExistence(timeout: 5))
        }
    }
}
