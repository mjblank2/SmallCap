import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // Initialize the global appearance for the dark theme
    init() {
        // Customize Tab Bar Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Use the card color for the tab bar background
        appearance.backgroundColor = UIColor(Color.backgroundCard) 
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Customize Navigation Bar Appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.backgroundCard)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some View {
        Group {
            if subscriptionManager.isPremiumUser {
                 TabView {
                    PicksListView()
                        .tabItem { Label("Picks", systemImage: "lightbulb.max.fill") }
                    
                    // NEW: Catalyst Feed Tab
                    EventsFeedView()
                        .tabItem { Label("Catalysts", systemImage: "bolt.horizontal.fill") }

                    ScorecardView()
                        .tabItem { Label("Scorecard", systemImage: "chart.bar.xaxis") }
                    
                    WatchlistView()
                         .tabItem { Label("Watchlist", systemImage: "star.fill") }

                    SettingsView()
                         .tabItem { Label("Settings", systemImage: "gear") }
                }
                // Apply the global accent color
                .accentColor(.brandAccent)
            } else {
                PaywallView()
            }
        }
        // Enforce Dark Mode globally for this design system
        .preferredColorScheme(.dark)
    }
}
