import SwiftUI

struct LoginView: View {
    // Default emails for easy testing against the simulated backend
    @State private var email: String = "user@example.com"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In").font(.largeTitle)
            
            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress).autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
            
            // Password field omitted as the simulation relies only on email
            
            if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red).font(.footnote)
            }

            Button("Login (Simulated)") {
                Task {
                    isLoading = true
                    errorMessage = nil
                    // If successful, AuthService updates its state, and AppRootView updates the UI.
                    let success = await authService.login(email: email)
                    if !success {
                        errorMessage = "Login failed. Check credentials and backend status."
                    }
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty)
            
            if isLoading { ProgressView() }

            Text("For testing use: 'user@example.com' or 'admin@example.com'.").font(.footnote).foregroundColor(.secondary).padding(.top, 20)
            
            // CRITICAL: App Store requires "Sign in with Apple" if other third-party logins are used.
            Text("Sign in with Apple integration required here for production.").font(.caption).foregroundColor(.gray)
        }
        .padding()
    }
}
