import Foundation
import SwiftUI

// Model for the Catalyst Feed
struct EventCatalyst: Codable, Identifiable {
    // Ensure ID parsing from backend UUID string
    let id: UUID
    let ticker: String
    let eventType: String
    let title: String
    let date: Date
    let impact: String? // High, Medium, Speculative
    
    var impactColor: Color {
        switch impact {
        case "High": return .red
        case "Speculative": return .orange
        default: return .yellow
        }
    }
    
    var iconName: String {
        switch eventType {
        case "SEC Filing (8-K)": return "doc.text.magnifyingglass"
        case "FDA Update": return "cross.case.fill"
        case "Earnings": return "dollarsign.circle.fill"
        default: return "newspaper.fill"
        }
    }
}
