// SnapshotHelper.swift (Standard Fastlane Boilerplate)
import Foundation
import XCTest

@available(iOS 9.0, *)
public func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
    Snapshot.setupSnapshot(app, waitForAnimations: waitForAnimations)
}

@available(iOS 9.0, *)
public func snapshot(_ name: String, waitForAnimations: Bool = true) {
    Snapshot.snapshot(name, waitForAnimations: waitForAnimations)
}

@available(iOS 9.0, *)
public class Snapshot: NSObject {
    public static var app: XCUIApplication?
    public static var waitForAnimations = true
    
    public class func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
        Snapshot.app = app
        Snapshot.waitForAnimations = waitForAnimations

        let bundle = Bundle(for: Snapshot.self)
        let deviceLanguage = bundle.preferredLocalizations[0]
        let deviceLocale = Locale(identifier: deviceLanguage).identifier
        
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-ui_testing"]
        app.launchArguments += ["-AppleLanguages", "(\(deviceLanguage))"]
        app.launchArguments += ["-AppleLocale", deviceLocale]
    }
    
    public class func snapshot(_ name: String, waitForAnimations: Bool = true) {
        if Snapshot.waitForAnimations && waitForAnimations {
            sleep(1) // Wait for animations
        }
        
        guard let app = Snapshot.app else { return }
        
        // Capturing the screenshot
        let screenshot = app.windows.firstMatch.screenshot()
        let image = screenshot.image
        
        // Saving the screenshot to a path recognized by Fastlane during the CI run
        let simulator = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"]
        // Fastlane sets the SNAPSHOT_PATH environment variable
        let snapshotBasePath = ProcessInfo().environment["SNAPSHOT_PATH"] ?? NSTemporaryDirectory()

        let path = "\(snapshotBasePath)/\(name)-\(simulator ?? "unknown").png"

        do {
            try image.pngData()?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print("Error saving snapshot: \(error)")
        }
    }
}

