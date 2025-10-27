import Foundation
import SwiftUI

struct StockIdea: Codable, Identifiable {
    // Ensure the ID from the backend (UUID string) can be parsed
    let id: UUID
    let ticker: String
    let companyName: String
    let thesis: String
    let riskLevel: RiskLevel
    let entryPrice: Double?
    let targetPrice: Double?
    let publicationDate: Date?
    
    // Enhanced Due Diligence Signals (Optional as they might not always be present)
    let signalInsider: String?
    let signalShortInterest: Double?
    let signalLiquidity: Int?
    
    // Calculated property for UI
    var potentialUpside: Double? {
        guard let entry = entryPrice, let target = targetPrice, entry > 0 else { return nil }
        return ((target - entry) / entry)
    }
    
    enum RiskLevel: String, Codable {
        case Speculative, High, Medium
        // Associated colors for UI
        var displayColor: Color {
            switch self {
            case .Speculative: return Color.red
            case .High: return Color.orange
            case .Medium: return Color.yellow
            }
        }
    }
}
