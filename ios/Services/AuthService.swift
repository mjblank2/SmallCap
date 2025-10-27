import Foundation
import Combine

// Manages the authentication state of the application
class AuthService: ObservableObject {
    static let shared = AuthService()
    // The central source of truth for authentication status
    @Published var isAuthenticated: Bool = false
    private let tokenAccount = "authToken"
    
    private init() {
        // Check Keychain on application startup
        self.isAuthenticated = (KeychainHelper.shared.get(account: tokenAccount) != nil)
    }
    
    func login(email: String) async -> Bool {
        // CRITICAL: In production, integrate a real provider (Firebase Auth, Auth0).
        // If using any third-party login, you MUST include "Sign in with Apple" (App Store Guideline 4.8).
        
        // Simulation: Communicating with the local backend
        let url = Environment.current.apiBaseURL.appendingPathComponent("auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Parse the token from the response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    
                    // Save securely to Keychain
                    KeychainHelper.shared.save(token: token, account: tokenAccount)
                    
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                    // CRITICAL: After login, immediately verify subscription status via SSRV pathway
                    await SubscriptionManager.shared.verifySubscriptionStatus()
                    return true
                }
            }
        } catch {
            print("Login failed: \(error)")
        }
        return false
    }
    
    func logout() {
        KeychainHelper.shared.delete(account: tokenAccount)
        DispatchQueue.main.async {
            self.isAuthenticated = false
            // Clear subscription status on logout
            SubscriptionManager.shared.isPremiumUser = false
        }
    }
    
    // Helper for APIService to retrieve the token
    func getAuthToken() -> String? {
        return KeychainHelper.shared.get(account: tokenAccount)
    }
}
