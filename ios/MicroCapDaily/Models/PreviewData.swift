import Foundation

struct PreviewData {
    // Idealized data for Dashboard
    static let idealPicks: [StockIdea] = [
        StockIdea(id: UUID(), ticker: "ACME", companyName: "Acme Dynamics", thesis: "Strong catalysts...", riskLevel: .Medium, entryPrice: 5.50, targetPrice: 12.00, publicationDate: Date(), convictionScore: 8.8, convictionClassification: "High Conviction", aiSummary: "• AI Summary bullet point 1\n• AI Summary bullet point 2"),
        StockIdea(id: UUID(), ticker: "BETA", companyName: "Beta BioInnovators", thesis: "Speculative play...", riskLevel: .Speculative, entryPrice: 1.10, targetPrice: 5.00, publicationDate: Date(), convictionScore: 7.2, convictionClassification: "Strong Opportunity", aiSummary: "• AI Summary bullet point 1")
    ]
    
    // Idealized data for Detail View
    static let idealAnalysisHub: AnalysisHub = AnalysisHub(
        ticker: "ACME",
        redFlags: RiskAnalysis(compositeRiskScore: 25.0, details: [
            RiskDetail(metric: "Cash Burn Rate", score: 10, insight: "Positive operating cash flow.", severity: .Low)
        ], error: nil),
        insiderActivity: InsiderActivity(sentiment: "Bullish", recentBuys: 550000, recentSells: 12000),
        liquidity: LiquidityScore(score: 85, spread: "$0.02", spreadPct: 0.3),
        sentiment: NewsSentiment(score: 0.65, sentiment: "Positive", articleCount: 12),
        fundamentalsChart: [],
        technicals: TechnicalAnalysis(trend: "Strong Uptrend", indicators: nil, signals: [
            TechnicalSignal(signal: "Golden Cross", sentiment: "Bullish", description: "50-day SMA crossed above 200-day SMA.")
        ], error: nil),
        ownership: InstitutionalOwnership(topHolders: [], concentration: 45.0)
    )
}
