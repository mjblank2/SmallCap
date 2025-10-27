import Foundation
// In production: import Mixpanel or import Amplitude

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    enum Event: String {
        case appLaunched = "App_Launched"
        case loginSuccess = "Login_Success"
        case paywallViewed = "Paywall_Viewed"
        case ideaViewed = "Idea_Viewed"
    }
    
    func track(_ event: Event, properties: [String: Any]? = nil) {
        Log.log("Analytics Event: \(event.rawValue). Properties: \(properties ?? [:])", level: .info)
        // In production: E.g., Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
    }
}
// Convenience wrapper
var Analytics = AnalyticsManager.shared
