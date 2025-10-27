import Foundation
import SwiftUI

// Comprehensive model for the Analysis Hub response
struct AnalysisHub: Codable {
    let ticker: String
    let redFlags: RiskAnalysis
    let insiderActivity: InsiderActivity
    let liquidity: LiquidityScore
    let sentiment: NewsSentiment
    let fundamentalsChart: [FinancialDataPoint]
}

// Sub-Models for specific features:

// 1. Red Flag Engine
struct RiskAnalysis: Codable {
    let compositeRiskScore: Double?
    let details: [RiskDetail]?
    let error: String? // Handle potential backend errors
}

struct RiskDetail: Codable, Identifiable {
    var id: String { metric }
    let metric: String
    let score: Double?
    let insight: String
    let severity: Severity
    
    enum Severity: String, Codable {
        case High, Medium, Low, Unknown
        
        var color: Color {
            switch self {
            case .High: return .red
            case .Medium: return .orange
            case .Low: return Color.brandPositive
            case .Unknown: return .gray
            }
        }
    }
}

// 2. Insider Activity
struct InsiderActivity: Codable {
    let sentiment: String // Bullish, Neutral, Bearish
    let recentBuys: Double
    let recentSells: Double
    
    var sentimentColor: Color {
        switch sentiment {
        case "Bullish": return .brandPositive
        case "Bearish": return .red
        default: return .gray
        }
    }
}

// 3. Liquidity Score
struct LiquidityScore: Codable {
    let score: Int
    let spread: String
    let spreadPct: Double?
    
    var scoreColor: Color {
        if score > 70 { return .brandPositive }
        if score > 40 { return .yellow }
        return .red
    }
}

// 4. News Sentiment
struct NewsSentiment: Codable {
    let score: Double
    let sentiment: String
    let articleCount: Int
}

// 5. Fundamental Visualization
struct FinancialDataPoint: Codable, Identifiable {
    var id: String { date }
    let date: Date // Requires specific DateFormatter
    let revenue: Double
    let netIncome: Double
}
