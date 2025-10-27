import SwiftUI

// Feature 3: Liquidity Score View
struct LiquidityScoreView: View {
    let liquidity: LiquidityScore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Liquidity Score")
                Text("Spread: \(liquidity.spread)")
                    .font(StyleGuide.Typography.caption)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Text("\(liquidity.score)/100")
                .font(StyleGuide.Typography.headline)
                .foregroundColor(liquidity.scoreColor)
            
            if liquidity.score < 40 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .help("Warning: Highly illiquid, wide spreads detected.")
            }
        }
    }
}

// Feature 4: News Sentiment View
struct NewsSentimentView: View {
    let sentiment: NewsSentiment
    
    var sentimentColor: Color {
        if sentiment.score > 0.1 { return .brandPositive }
        if sentiment.score < -0.1 { return .red }
        return .gray
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("News Sentiment")
                Text("Based on \(sentiment.articleCount) articles")
                    .font(StyleGuide.Typography.caption)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Text(sentiment.sentiment)
                .font(StyleGuide.Typography.headline)
                .foregroundColor(sentimentColor)
        }
    }
}
