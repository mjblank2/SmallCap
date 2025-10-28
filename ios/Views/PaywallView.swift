import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                Text("Unlock Expert Micro-Cap Analysis")
                    .font(StyleGuide.Typography.screenTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.textPrimary)
                
                Text("Gain access to professionally curated ideas, detailed theses, and our full performance track record.")
                    .font(StyleGuide.Typography.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button(action: {
                    Task { await subscriptionManager.purchasePremium() }
                }) {
                    // Display the dynamic price fetched by SubscriptionManager from StoreKit
                    Text("Subscribe Now (\(subscriptionManager.premiumProductPrice))")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandAccent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button("Restore Purchases") {
                     Task { await subscriptionManager.restorePurchases() }
                }
                .font(.footnote)
                .tint(.brandAccent)
                
                 // CRITICAL: Must link to actual policies for App Store approval
                 Text("Terms of Service and Privacy Policy apply.") 
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .task {
            // Fetch product details when the paywall appears
            await subscriptionManager.fetchProductDetails()
        }
    }
}

