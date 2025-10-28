import Foundation
import LocalAuthentication
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var isBiometricsEnabled: Bool = false
    @Published var isAppLocked: Bool = false // Manages the lock screen state
    
    private let biometricsKey = "biometricsEnabled"
    private let authAccount = "authToken" // Keychain account key

    private init() {
        // Check keychain on init
        if let token = KeychainHelper.shared.get(account: authAccount), !token.isEmpty {
            self.isAuthenticated = true
        }
        initializeBiometrics()
    }
    
    // Call this in the init() function (after setting isAuthenticated)
    func initializeBiometrics() {
        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: biometricsKey)
        // Lock initially if biometrics is enabled and user is authenticated
        if self.isBiometricsEnabled && self.isAuthenticated {
            self.isAppLocked = true
        }
    }
    
    func setBiometricsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: biometricsKey)
        self.isBiometricsEnabled = enabled
        // If user is enabling it, lock the app
        if enabled {
            self.isAppLocked = self.isAuthenticated
        }
        Haptics.impactLight()
    }
    
    func attemptBiometricUnlock() async {
        guard isBiometricsEnabled, isAppLocked else { return }
        let context = LAContext()
        // CRITICAL: Ensure NSFaceIDUsageDescription is added to Info.plist
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            let reason = "Unlock access to your financial insights."
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                if success {
                    DispatchQueue.main.async { self.isAppLocked = false }
                    Haptics.notifySuccess()
                }
            } catch {
                Log.reportError(error, context: "Biometric auth failed")
            }
        }
    }
    
    // Called when the app moves to the background
    func lockApp() {
        if isBiometricsEnabled && isAuthenticated {
            DispatchQueue.main.async { self.isAppLocked = true }
        }
    }
    
    // --- Authentication Flow ---
    
    func login(email: String) async -> Bool {
        // --- SIMULATION ---
        // In production: Call Firebase Auth, Sign in with Apple, etc.
        // On success, get the JWT token from the auth provider.
        let simUsers = ["user@example.com": "VALID_USER_TOKEN", "admin@example.com": "VALID_ADMIN_TOKEN"]
        guard let token = simUsers[email] else {
            return false // Simulated failed login
        }
        // --- END SIMULATION ---

        // Save token securely
        KeychainHelper.shared.save(token: token, account: authAccount)
        
        // Update app state
        DispatchQueue.main.async {
            self.isAuthenticated = true
            if self.isBiometricsEnabled {
                self.isAppLocked = true // Lock on login if biometrics is on
            }
        }
        
        // Identify with other services
        await SubscriptionManager.shared.identifyUser(userId: email) // Use real UID here
        Analytics.track(.loginSuccess, properties: ["email": email])
        return true
    }
    
    @MainActor
    func logout() {
        // Clear token
        KeychainHelper.shared.delete(account: authAccount)
        
        // Clear app state
        self.isAuthenticated = false
        self.isAppLocked = false // Ensure app is unlocked on logout
        
        // Log out of services
        Task { await SubscriptionManager.shared.logoutUser() }
    }
}
