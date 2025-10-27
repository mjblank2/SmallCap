import XCTest

class MicroCapDailyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Initialize Fastlane Snapshot helper (requires SnapshotHelper.swift)
        setupSnapshot(app)
        
        // CRITICAL: Launch Arguments
        // These arguments tell the main app to bypass auth and load idealized mock data.
        app.launchArguments.append("UITESTING_MODE")
        app.launchArguments.append("BYPASS_AUTH")
        app.launchArguments.append("LOAD_PREVIEW_DATA")
        
        app.launch()
        handleSystemAlerts()
    }

    func testGenerateScreenshots() throws {
        // 1. Dashboard
        // Wait for the main dashboard to appear. Use the personalized greeting (e.g., "Good Morning") or "Dashboard".
        let dashboardTitle = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 15))
        
        snapshot("01_Dashboard")
        
        // 2. Navigate to Detail View
        // Tap the first card on the dashboard. Assumes mock data provides at least one card.
        let firstPickCard = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstPickCard.waitForExistence(timeout: 5))
        firstPickCard.tap()
        
        // Wait for a key element on the detail view (e.g., "Thesis & Conviction" header)
        XCTAssertTrue(app.staticTexts["Thesis & Conviction"].waitForExistence(timeout: 10))

        // 3. Capture Detail View (Top)
        snapshot("02_PickDetail")
        
        // Scroll down to show analysis features
        // SwiftUI Lists often compile to UICollectionViews or UITableViews
        let mainScrollView = app.collectionViews.firstMatch
        if mainScrollView.exists {
            mainScrollView.swipeUp()
            mainScrollView.swipeUp()
        }

        // 4. Capture Detail View (Analysis Hub)
        snapshot("03_AnalysisHub")
        
        // Navigate back
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // 5. Navigate to Catalyst Feed (Tab 2)
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars["Catalyst Feed"].waitForExistence(timeout: 5))
        
        // 6. Capture Catalyst Feed
        snapshot("04_CatalystFeed")
        
        // 7. Navigate to Scorecard (Tab 3)
        app.tabBars.buttons.element(boundBy: 2).tap()
        XCTAssertTrue(app.navigationBars["Scorecard"].waitForExistence(timeout: 5))
        
        // 8. Capture Scorecard
        snapshot("05_Scorecard")
    }
    
    // Helper to handle potential "Allow Notifications" system prompt during testing
    func handleSystemAlerts() {
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            return false
        }
    }
}
