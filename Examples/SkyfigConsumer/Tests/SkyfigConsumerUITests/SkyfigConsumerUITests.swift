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
        for title in ["Overview", "Components", "Content", "Planning", "Accessibility"] {
            XCTAssertTrue(navigationItem(named: title).waitForExistence(timeout: 5))
        }
    }

    func testEveryTabPresentsItsTokenDrivenContent() {
        let expectations = [
            (tab: "Overview", content: "Design system preview"),
            (tab: "Components", content: "Button states"),
            (tab: "Content", content: "Today"),
            (tab: "Planning", content: "Sprint plan"),
            (tab: "Accessibility", content: "Showcase.Accessibility"),
        ]

        for expectation in expectations {
            navigationItem(named: expectation.tab).tap()
            XCTAssertTrue(contentElement(named: expectation.content).waitForExistence(timeout: 5))
        }
    }

    func testOverviewRemainsUsableAtAnAccessibilityTextSize() {
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

    func testAccessibilityTabExplainsReducedMotionBehavior() {
        navigationItem(named: "Accessibility").tap()
        let motionControl = app.buttons["Select motion preview"]
        var scrollAttempts = 0
        while !motionControl.exists && scrollAttempts < 3 {
            app.swipeUp()
            scrollAttempts += 1
        }
        XCTAssertTrue(motionControl.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Readable at larger text sizes"].exists)
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

    func testCaptureSnapshotTabs() {
        let expectations = [
            (tab: "Overview", content: "Design system preview"),
            (tab: "Components", content: "Button states"),
            (tab: "Content", content: "Today"),
            (tab: "Planning", content: "Sprint plan"),
            (tab: "Accessibility", content: "Showcase.Accessibility"),
        ]

        for expectation in expectations {
            if expectation.tab != "Overview" {
                app.terminate()
                app.launch()
                XCTAssertTrue(app.staticTexts["Design system preview"].waitForExistence(timeout: 5))
            }

            navigationItem(named: expectation.tab).tap()
            XCTAssertTrue(contentElement(named: expectation.content).waitForExistence(timeout: 5))
            Thread.sleep(forTimeInterval: 1)

            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = "skyfig-\(expectation.tab.lowercased())-light"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    private func navigationItem(named title: String) -> XCUIElement {
        let button = app.buttons[title].firstMatch
        if button.exists && button.isHittable {
            return button
        }

        let cell = app.cells[title].firstMatch
        if cell.exists && cell.isHittable {
            return cell
        }

        return app.descendants(matching: .any)[title].firstMatch
    }

    private func typographySample(named name: String) -> XCUIElement {
        app.descendants(matching: .any)["Typography.\(name)"]
    }

    private func contentElement(named name: String) -> XCUIElement {
        let staticText = app.staticTexts[name]
        return staticText.exists ? staticText : app.descendants(matching: .any)[name]
    }
}
