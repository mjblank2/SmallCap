import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Unlock Expert Micro-Cap Analysis")
                .font(.largeTitle).bold().multilineTextAlignment(.center).padding(.horizontal)
            
            Text("Gain access to professionally curated ideas, detailed theses, and our full performance track record.")
                .multilineTextAlignment(.center).padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                Task { await subscriptionManager.purchasePremium() }
            }) {
                // Display the dynamic price fetched by SubscriptionManager from StoreKit
                Text("Subscribe Now (\(subscriptionManager.premiumProductPrice))")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    // Use the Emerald Green accent color
                    .background(Color(red: 4/255, green: 167/255, blue: 119/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Restore Purchases") {
                 Task { await subscriptionManager.restorePurchases() }
            }.font(.footnote)
            
             // CRITICAL: Must link to actual policies for App Store approval
             Text("Terms of Service and Privacy Policy apply.") 
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .task {
            // Fetch product details when the paywall appears
            await subscriptionManager.fetchProductDetails()
        }
    }
}
