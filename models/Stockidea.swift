import Foundation
import SwiftUI

struct StockIdea: Codable, Identifiable {
    // Ensure the ID coming from the API can be parsed as a UUID
    let id: UUID
    let ticker: String
    let companyName: String
    let investmentThesis: String
    let riskLevel: RiskLevel
    let entryPrice: Double
    let targetPrice: Double
    let publicationDate: Date
    
    // Feature: Calculate Potential Upside
    var potentialUpside: Double? {
        guard entryPrice > 0 else { return nil }
        return ((targetPrice - entryPrice) / entryPrice)
    }
    
    // Feature: Generate SEC Edgar search URL (Due Diligence Hub)
    var secEdgarURL: URL? {
        // Constructing the URL for SEC filings search (Category 1 = 10-K/10-Q/8-K)
        let encodedTicker = ticker.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ticker
        return URL(string: "https://www.sec.gov/edgar/search/#/q=\(encodedTicker)&entityName=\(encodedTicker)&category=form-cat1")
    }
}

enum RiskLevel: String, Codable {
    case speculative = "Speculative"
    case high = "High"
    case medium = "Medium"
    
    // Associated colors for UI visualization
    var displayColor: Color {
        switch self {
        case .speculative: return Color.red
        case .high: return Color.orange
        case .medium: return Color.yellow
        }
    }
}
