import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // URL provided by Apple for managing subscriptions (Mandatory)
    let manageSubscriptionURL = URL(string: "https://apps.apple.com/account/subscriptions")!
    
    var body: some View {
        NavigationStack {
            List {
                // NEW: Subscription Management Section
                Section(header: Text("Subscription")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(subscriptionManager.isPremiumUser ? "Premium Active" : "Free Tier")
                            .foregroundColor(subscriptionManager.isPremiumUser ? .green : .secondary)
                    }
                    
                    Link("Manage Subscription", destination: manageSubscriptionURL)
                    
                    // Restore purchases button (Required by Apple)
                    Button("Restore Purchases") {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                }
                
                // ... (Account and Legal sections remain) ...
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}
