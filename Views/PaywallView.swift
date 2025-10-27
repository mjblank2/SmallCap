import SwiftUI

struct PaywallView: View {
    let primaryColor: Color
    let accentColor: Color
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Unlock Expert Micro-Cap Analysis")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Get access to professionally curated ideas, analyzed daily by our experts.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 15) {
                FeatureBullet(text: "Daily Curated Ideas (Hybrid Model)", color: accentColor)
                FeatureBullet(text: "Detailed Investment Thesis & Catalysts", color: accentColor)
                FeatureBullet(text: "Integrated Due Diligence Tools", color: accentColor)
            }
            .padding(.vertical)
            
            Spacer()
            
            Button(action: {
                Task { await subscriptionManager.purchasePremium() }
            }) {
                // NOTE: Price must be fetched dynamically from StoreKit in production
                Text("Subscribe Now ($49.99/mo)") 
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Restore Purchases") {
                Task { await subscriptionManager.restorePurchases() }
            }
            .font(.footnote)
            
            // Must link to actual policies for App Store approval
            Text("Terms of Service and Privacy Policy apply.") 
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct FeatureBullet: View {
    let text: String
    let color: Color
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(color)
            Text(text)
        }
    }
}
