// iOS/Views/MainTabView.swift (Excerpt)
struct MainTabView: View {
    // ... (Environment Objects)
    @StateObject private var pushHandler = PushNotificationHandler.shared
    @State private var showingNotificationPrimer = false
    @AppStorage("hasShownNotificationPrimer") private var primerAlreadyShown: Bool = false

    // ... (init for appearance) ...

    var body: some View {
        Group {
            if subscriptionManager.isPremiumUser {
                 TabView {
                    // DashboardView replaces PicksListView
                    DashboardView()
                        .tabItem { Label("Dashboard", systemImage: "house.fill") }
                    
                    // ... (Other Tabs: Catalysts, Scorecard, Watchlist, Settings) ...
                }
                .accentColor(.brandAccent)
                // NEW: Present the notification primer modally
                .sheet(isPresented: $showingNotificationPrimer) {
                    NotificationPrimerView()
                }
                .onAppear {
                    // Logic to decide when to show the primer
                    if !pushHandler.permissionGranted && !primerAlreadyShown {
                        // Delay slightly after launch for a smoother experience
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showingNotificationPrimer = true
                            primerAlreadyShown = true
                        }
                    }
                }
            } else {
                PaywallView()
            }
        }
    }
}
