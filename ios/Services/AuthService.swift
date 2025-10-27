// iOS/Services/AuthService.swift (Excerpt)
import LocalAuthentication
import Combine

class AuthService: ObservableObject {
    // ... (existing properties: isAuthenticated) ...
    @Published var isBiometricsEnabled: Bool = false
    @Published var isAppLocked: Bool = false // Manages the lock screen state
    
    private let biometricsKey = "biometricsEnabled"

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
        self.isAppLocked = enabled && self.isAuthenticated
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
                print("Biometric Authentication Failed.")
            }
        }
    }
    
    // Called when the app moves to the background
    func lockApp() {
        if isBiometricsEnabled && isAuthenticated {
            DispatchQueue.main.async { self.isAppLocked = true }
        }
    }
    
    func logout() {
        // ... (existing logout logic) ...
        DispatchQueue.main.async { 
            self.isAuthenticated = false
            self.isAppLocked = false // Ensure app is unlocked on logout
        }
    }
}
