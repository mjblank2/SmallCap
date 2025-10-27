import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome and Value Proposition
            OnboardingPageView(
                title: "Welcome to MicroCap Daily",
                subtitle: "Discover high-potential small-cap and micro-cap stocks analyzed by experts.",
                imageName: "chart.line.uptrend.xyaxis.circle.fill",
                showNextButton: true,
                currentPage: $currentPage
            ).tag(0)
            
            // Page 2: Our Methodology (The Hybrid Model)
            OnboardingPageView(
                title: "The Hybrid Approach",
                subtitle: "We combine sophisticated algorithms with rigorous human due diligence to mitigate risks.",
                imageName: "person.2.badge.gearshape.fill",
                showNextButton: true,
                currentPage: $currentPage
            ).tag(1)

            // Page 3: Compliance and Risk Warning (Mandatory)
            RiskWarningView(onboardingCompleted: $onboardingCompleted).tag(2)
        }
        // Creates the paging effect
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            Analytics.track(.appLaunched)
        }
    }
}

// Helper View for standard pages (Implementation Details Omitted for Brevity)
struct OnboardingPageView: View { /* ... */ }

// Specialized View for the Risk Warning (Implementation Details Omitted for Brevity)
struct RiskWarningView: View { /* ... */ }
