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
                DispatchQueue.main.async {
                    // Register for remote notifications (triggers system callbacks to get the token)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // Called when the device successfully registers (Must be hooked into App Delegate)
    func registerToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Task { await sendTokenToBackend(token: tokenString) }
    }
    
    private func sendTokenToBackend(token: String) async {
        guard AuthService.shared.isAuthenticated else { return }
        // IMPLEMENTATION REQUIRED: Use APIService to call /api/v1/user/register_device
        print("Successfully sent device token to backend (Simulated).")
    }
}
