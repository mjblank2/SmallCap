import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        // Check subscription status. If premium, show content. If not, show the Paywall.
        if subscriptionManager.isPremiumUser {
             TabView {
                PicksListView()
                    .tabItem { Label("Today's Picks", systemImage: "lightbulb.max.fill") }
                
                ScorecardView()
                    .tabItem { Label("Scorecard", systemImage: "chart.bar.xaxis") }
                
                WatchlistView()
                     .tabItem { Label("Watchlist", systemImage: "star.fill") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            // Set a global accent color (e.g., Emerald Green for growth)
            .accentColor(Color(red: 4/255, green: 167/255, blue: 119/255))
        } else {
            // Authenticated but not subscribed (e.g., subscription lapsed)
            PaywallView()
        }
    }
}
