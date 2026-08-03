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

    private func navigationItem(named title: String) -> XCUIElement {
        let tabBarButton = app.tabBars.buttons[title]
        return tabBarButton.exists ? tabBarButton : app.cells[title]
    }
}
