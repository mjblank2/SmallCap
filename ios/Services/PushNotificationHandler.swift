import Foundation
import UserNotifications
import UIKit

// Handles requesting permission and token registration.
class PushNotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationHandler()
    @Published var permissionGranted: Bool = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    // The actual system prompt request (called after the primer view)
    func requestSystemPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async { self.permissionGranted = granted }
            if granted {
                Log.log("Notification permission granted.", level: .info)
                DispatchQueue.main.async {
                    // Register for remote notifications (triggers system callbacks to get the token)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Log.log("Notification permission denied.", level: .warning)
            }
        }
    }
    
    // Called when the device successfully registers (Must be hooked into App Delegate)
    func registerToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Log.log("Received APNs token: \(tokenString)", level: .info)
        Task { await sendTokenToBackend(token: tokenString) }
    }
    
    // --- GAP 1 Fix: Call APIService ---
    private func sendTokenToBackend(token: String) async {
        guard AuthService.shared.isAuthenticated else {
            Log.log("User not authenticated, skipping token registration.", level: .info)
            return
        }
        // Use the APIService to send the token
        await APIService.shared.registerDeviceToken(token)
    }
    
    // --- Delegate Methods ---
    
    // Handle notification when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle user tapping on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the deep link, e.g., navigate to a specific ticker
        let userInfo = response.notification.request.content.userInfo
        Log.log("User tapped notification: \(userInfo)", level: .info)
        
        // Example: if let ticker = userInfo["ticker"] as? String {
        //    NotificationCenter.default.post(name: .deepLinkToTicker, object: ticker)
        // }
        
        completionHandler()
    }
}
