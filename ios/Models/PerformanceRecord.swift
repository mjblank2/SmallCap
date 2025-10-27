import Foundation

// Model for the Scorecard/Track Record feature
struct PerformanceRecord: Codable, Identifiable {
    let id: UUID
    let ticker: String
    let publicationDate: Date?
    let status: String // Open, Closed
    let returnPct: Double?
}
