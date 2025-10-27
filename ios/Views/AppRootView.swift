import SwiftUI

struct AppRootView: View {
    @StateObject private var authService = AuthService.shared
    // ... (other StateObjects)
    @StateObject private var networkMonitor = NetworkMonitor.shared // For Network Status
    @Environment(\.scenePhase) private var scenePhase // For background locking

    @AppStorage("hasCompletedOnboarding") private var onboardingCompleted: Bool = false

    var body: some View {
        ZStack {
            // Main Content Flow
            Group {
                if !onboardingCompleted {
                    OnboardingView(onboardingCompleted: $onboardingCompleted)
                } else if authService.isAuthenticated {
                    // Check for Biometric Lock
                    if authService.isAppLocked {
                        BiometricLockView()
                    } else {
                        MainTabView()
                    }
                } else {
                    LoginView()
                }
            }
            
            // Network Status Overlay (Robustness)
            if !networkMonitor.isConnected {
                VStack {
                    HStack {
                        Image(systemName: "wifi.exclamationmark")
                        Text("No Internet Connection. Data may be outdated.")
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding(.top, 50) 
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: networkMonitor.isConnected)
            }
        }
        // ... (environmentObjects injection) ...
        .preferredColorScheme(.dark)
        // Handle app moving to background (Security)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                authService.lockApp()
            }
        }
        .onAppear {
            authService.initializeBiometrics()
        }
    }
}

// NEW Helper View for the Lock Screen
struct BiometricLockView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: "faceid").font(.system(size: 60)).foregroundColor(.brandAccent)
                Text("App Locked").font(StyleGuide.Typography.screenTitle)
                Button("Unlock Now") {
                    Task { await authService.attemptBiometricUnlock() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.brandAccent)
            }
        }
        .task {
            await authService.attemptBiometricUnlock()
        }
    }
}
