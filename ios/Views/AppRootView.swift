import SwiftUI

// The root view manages the application state transitions: 
// Onboarding -> Authentication -> Main Content (Premium or Paywall)
struct AppRootView: View {
    // Observe the centralized services
    @StateObject private var authService = AuthService.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var watchlistVM = WatchlistViewModel.shared
    
    // Use AppStorage (UserDefaults wrapper) for simple flags like onboarding completion
    @AppStorage("hasCompletedOnboarding") private var onboardingCompleted: Bool = false

    var body: some View {
        Group {
            if !onboardingCompleted {
                // 1. Compliance Flow
                OnboardingView(onboardingCompleted: $onboardingCompleted)
            } else if authService.isAuthenticated {
                // 2. Authenticated State: Check Subscription (Handled within MainTabView)
                MainTabView()
            } else {
                // 3. Unauthenticated State
                LoginView()
            }
        }
        // Inject managers into the environment for use throughout the app hierarchy
        .environmentObject(authService)
        .environmentObject(subscriptionManager)
        .environmentObject(watchlistVM)
    }
}
