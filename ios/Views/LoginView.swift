import SwiftUI

struct LoginView: View {
    // Default emails for easy testing against the simulated backend
    @State private var email: String = "user@example.com"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.brandAccent)
                
                Text("MicroCap Daily")
                    .font(StyleGuide.Typography.screenTitle)
                    .foregroundColor(.textPrimary)
                
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress).autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .tint(.brandAccent)
                
                // Password field omitted as the simulation relies only on email
                
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red).font(.footnote)
                }

                Button(action: { Task { await performLogin() } }) {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Login (Simulated)")
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.brandAccent)
                .padding(.horizontal)
                .disabled(isLoading || email.isEmpty)
                
                Text("For testing use: 'user@example.com' or 'admin@example.com'.")
                    .font(.footnote).foregroundColor(.secondary).padding(.top, 20)
                
                Spacer()
                
                // CRITICAL: App Store requires "Sign in with Apple"
                Text("Sign in with Apple integration required here for production.")
                    .font(.caption).foregroundColor(.gray)
                    .padding(.bottom)
            }
            .padding()
        }
    }
    
    func performLogin() async {
        isLoading = true
        errorMessage = nil
        // If successful, AuthService updates its state, and AppRootView updates the UI.
        let success = await authService.login(email: email)
        if !success {
            errorMessage = "Login failed. Check credentials and backend status."
            Haptics.notifyWarning()
        }
        // isLoading is set to false implicitly by AuthService state change
    }
}

