import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var showingDeleteAlert = false
    @State private var isDeletingAccount = false

    var body: some View {
        NavigationStack {
            ZStack {
                 Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                List {
                    // Subscription Section
                    Section(header: Text("Subscription").foregroundColor(.textSecondary)) {
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(subscriptionManager.isPremiumUser ? "Premium" : "Free")
                                .foregroundColor(subscriptionManager.isPremiumUser ? .brandPositive : .textSecondary)
                        }
                        Button("Manage Subscription") {
                            // Implement logic to open App Store subscription management
                        }
                        Button("Restore Purchases") {
                            Task { await subscriptionManager.restorePurchases() }
                        }
                    }
                    .listRowBackground(Color.backgroundCard)

                    // Security Section (Biometrics)
                    Section(header: Text("Security").foregroundColor(.textSecondary)) {
                        Toggle(isOn: Binding(
                            get: { authService.isBiometricsEnabled },
                            set: { authService.setBiometricsEnabled($0) }
                        )) {
                            Label("Use Face ID / Touch ID", systemImage: "faceid")
                        }
                        .tint(.brandAccent)
                    }
                    .listRowBackground(Color.backgroundCard)

                    // ... (Legal Section - Ensure links are finalized) ...
                    Section(header: Text("Legal").foregroundColor(.textSecondary)) {
                         Button("Terms of Service") { /* Open URL */ }
                         Button("Privacy Policy") { /* Open URL */ }
                    }
                    .listRowBackground(Color.backgroundCard)


                    // Account Management
                    Section(header: Text("Account").foregroundColor(.textSecondary)) {
                        Button("Log Out") {
                            Haptics.impactLight()
                            authService.logout()
                        }
                        
                        // CRITICAL: Account Deletion (Gap 2 Fix)
                        Button("Delete Account") {
                            Haptics.notifyWarning()
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    .listRowBackground(Color.backgroundCard)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .disabled(isDeletingAccount)
                
                if isDeletingAccount {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView("Deleting Account...").tint(.white)
                }
            }
            .navigationTitle("Settings")
            // Confirmation Alert for Deletion (Mandatory Safety Feature)
            .alert("Confirm Account Deletion", isPresented: $showingDeleteAlert) {
                Button("Delete Forever", role: .destructive) {
                    // --- GAP 2 Fix ---
                    Task {
                        isDeletingAccount = true
                        do {
                            try await APIService.shared.deleteAccount()
                            Log.log("Account deletion successful. Logging out.", level: .info)
                            Haptics.notifySuccess()
                            // Log out after deletion completes
                            authService.logout()
                        } catch {
                            Log.reportError(error, context: "Account deletion failed")
                            Haptics.notifyWarning()
                            // Show another alert informing user of failure
                        }
                        isDeletingAccount = false
                    }
                    // --- End Fix ---
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your data, watchlist, and subscription status will be permanently deleted.")
            }
        }
    }
}
