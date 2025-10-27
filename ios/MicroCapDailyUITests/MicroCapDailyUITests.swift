import XCTest

class MicroCapDailyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Initialize Fastlane Snapshot helper
        setupSnapshot(app)
        
        // CRITICAL: Launch Arguments to tell the main app to load mock data and bypass auth.
        // The main app (AuthService/APIService) MUST be coded to recognize these arguments and load PreviewData.swift.
        app.launchArguments.append("UITESTING_MODE")
        app.launchArguments.append("BYPASS_AUTH")
        app.launchArguments.append("LOAD_PREVIEW_DATA")
        
        app.launch()
    }

    func testGenerateScreenshots() throws {
        // 1. Dashboard
        XCTAssertTrue(app.navigationBars.element(boundBy: 0).waitForExistence(timeout: 15))
        snapshot("01_Dashboard")
        
        // 2. Navigate to Detail View
        // Assumes the Dashboard uses a ScrollView and the cards are identifiable as buttons.
        let firstPickCard = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstPickCard.waitForExistence(timeout: 5))
        firstPickCard.tap()
        
        // Wait for a specific element on the detail screen
        XCTAssertTrue(app.staticTexts["Thesis & Conviction"].waitForExistence(timeout: 10))

        // 3. Capture Detail View (Top)
        snapshot("02_PickDetail")
        
        // Scroll down (SwiftUI Lists often compile to CollectionViews or TableViews)
        let mainScrollView = app.collectionViews.firstMatch
        if mainScrollView.exists {
            mainScrollView.swipeUp()
            mainScrollView.swipeUp()
        }

        // 4. Capture Detail View (Analysis Hub)
        snapshot("03_AnalysisHub")
        
        // 5. Navigate to Catalyst Feed (Tab 2 - adjust index if needed)
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars["Catalyst Feed"].waitForExistence(timeout: 5))
        snapshot("04_CatalystFeed")
    }
}
