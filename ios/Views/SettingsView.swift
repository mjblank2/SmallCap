import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    // ...
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                 Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                List {
                    // ... (Subscription Section) ...

                    // Security Section (Biometrics)
                    Section(header: Text("Security").foregroundColor(.textSecondary)) {
                        Toggle(isOn: Binding(
                            get: { authService.isBiometricsEnabled },
                            set: { authService.setBiometricsEnabled($0) }
                        )) {
                            Label("Use Face ID / Touch ID", systemImage: "faceid")
                        }
                    }
                    .listRowBackground(Color.backgroundCard)

                    // ... (Legal Section - Ensure links are finalized) ...

                    // Account Management
                    Section(header: Text("Account").foregroundColor(.textSecondary)) {
                        Button("Log Out") {
                            Haptics.impactLight()
                            authService.logout()
                        }
                        
                        // CRITICAL: Account Deletion (App Store Guideline 5.1.1 (v))
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
            }
            .navigationTitle("Settings")
            // Confirmation Alert for Deletion (Mandatory Safety Feature)
            .alert("Confirm Account Deletion", isPresented: $showingDeleteAlert) {
                Button("Delete Forever", role: .destructive) {
                    // IMPLEMENTATION REQUIRED: Initiate deletion flow (Backend API and Auth Provider)
                    print("Account deletion confirmed and initiated...")
                    Haptics.notifySuccess()
                    authService.logout() // Log out after deletion
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your data and subscription status will be permanently deleted.")
            }
        }
    }
}
