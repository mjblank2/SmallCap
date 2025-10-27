import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Account")) {
                    Button("Log Out") {
                        authService.logout()
                    }
                    .foregroundColor(.red)
                }
                
                 // CRITICAL: Links to actual, finalized policies are mandatory for App Store approval
                 Section(header: Text("Legal")) {
                    Link("Terms of Service", destination: URL(string: "https://yourdomain.com/terms")!)
                    Link("Privacy Policy", destination: URL(string: "https://yourdomain.com/privacy")!)
                    Link("Financial Disclaimer", destination: URL(string: "https://yourdomain.com/disclaimer")!)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}
