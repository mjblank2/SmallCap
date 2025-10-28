import SwiftUI

// Feature 2: Insider Activity View
struct InsiderActivityView: View {
    let activity: InsiderActivity
    
    // Helper for formatting large currency numbers
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.notation = .compactName
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Overall Sentiment (180 Days)")
                    .font(StyleGuide.Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text(activity.sentiment)
                    .font(StyleGuide.Typography.headline)
                    .foregroundColor(activity.sentimentColor)
            }
            
            // Visualization of Buys vs Sells
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Buys").foregroundColor(.textSecondary)
                    Text(formatter.string(from: NSNumber(value: activity.recentBuys)) ?? "$0")
                        .font(StyleGuide.Typography.cardTitle)
                        .foregroundColor(.brandPositive)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total Sells").foregroundColor(.textSecondary)
                    Text(formatter.string(from: NSNumber(value: activity.recentSells)) ?? "$0")
                        .font(StyleGuide.Typography.cardTitle)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
