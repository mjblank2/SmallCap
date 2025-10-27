import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @State private var acceptedRisks = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to MicroCap Daily").font(.largeTitle).bold().padding(.top, 50)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("CRITICAL RISK WARNING").font(.title2).bold().foregroundColor(.red)
                
                Text("Micro-cap and small-cap stocks are highly speculative, often illiquid, and carry extreme risk, including the total loss of your investment principal.")
                
                Text("This application is for informational and educational purposes ONLY and is NOT personalized investment advice. You are solely responsible for your investment decisions.")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            Spacer()
            
            Toggle("I have read, understood, and accept the risks.", isOn: $acceptedRisks)

            Button("Continue") {
                if acceptedRisks { onboardingCompleted = true }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!acceptedRisks)
            .padding(.bottom, 20)
        }
        .padding()
    }
}
