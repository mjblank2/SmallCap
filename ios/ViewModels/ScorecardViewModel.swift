import Foundation

@MainActor
class ScorecardViewModel: ObservableObject {
    @Published var history: [PerformanceRecord] = []
    @Published var isLoading: Bool = false
    
    // Calculated Metrics for the dashboard summary
    @Published var averageReturn: Double = 0.0
    @Published var winRate: Double = 0.0

    func loadHistory() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let records = try await APIService.shared.fetchPerformanceHistory()
            // Sort by date descending
            self.history = records.sorted(by: { $0.publicationDate ?? Date.distantPast > $1.publicationDate ?? Date.distantPast })
            calculateMetrics(records: records)
        } catch {
            print("Error loading history: \(error)")
            // Handle error state (e.g., display an alert)
        }
    }
    
    // Calculate key performance indicators (KPIs)
    private func calculateMetrics(records: [PerformanceRecord]) {
        guard !records.isEmpty else { return }
        
        // Filter out entries without valid return data
        let validReturns = records.compactMap { $0.returnPct }
        if validReturns.isEmpty { return }

        // Calculate Average Return
        let totalReturn = validReturns.reduce(0, +)
        self.averageReturn = totalReturn / Double(validReturns.count)
        
        // Calculate Win Rate
        let wins = validReturns.filter { $0 > 0 }.count
        self.winRate = Double(wins) / Double(validReturns.count)
    }
}
