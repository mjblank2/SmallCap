import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Welcome and Value Proposition
                OnboardingPageView(
                    title: "Welcome to MicroCap Daily",
                    subtitle: "Discover high-potential small-cap and micro-cap stocks analyzed by experts.",
                    imageName: "chart.line.uptrend.xyaxis.circle.fill"
                ).tag(0)
                
                // Page 2: Our Methodology (The Hybrid Model)
                OnboardingPageView(
                    title: "The Hybrid Approach",
                    subtitle: "We combine sophisticated algorithms with rigorous human due diligence to mitigate risks.",
                    imageName: "person.2.badge.gearshape.fill"
                ).tag(1)

                // Page 3: Compliance and Risk Warning (Mandatory)
                RiskWarningView(onboardingCompleted: $onboardingCompleted).tag(2)
            }
            // Creates the paging effect
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentPage ? Color.brandAccent : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color.backgroundMain.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .onAppear {
            Analytics.track(.appLaunched)
        }
    }
}

// Helper View for standard pages
struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.brandAccent)
            
            Text(title)
                .font(StyleGuide.Typography.screenTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.textPrimary)
            
            Text(subtitle)
                .font(StyleGuide.Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            Spacer()
        }
        .padding(30)
    }
}

// Specialized View for the Risk Warning
struct RiskWarningView: View {
    @Binding var onboardingCompleted: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 100))
                .foregroundColor(.orange)
            
            Text("Understand The Risk")
                .font(StyleGuide.Typography.screenTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.textPrimary)
            
            Text("Micro-cap investing is highly speculative and carries extreme risk. This is NOT financial advice. You can lose your entire investment. Never invest more than you can afford to lose.")
                .font(StyleGuide.Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("I Understand and Accept the Risk") {
                Haptics.notifySuccess()
                onboardingCompleted = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.brandAccent)
            
            Spacer()
        }
        .padding(30)
    }
}
