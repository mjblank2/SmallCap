import Foundation

// Manages the state for the detailed analysis view
@MainActor
class AnalysisViewModel: ObservableObject {
    let ticker: String
    
    @Published var analysisHub: AnalysisHub?
    @Published var isLoading = true
    @Published var errorMessage: String?

    init(ticker: String) {
        self.ticker = ticker
    }
    
    func loadAnalysis() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            self.analysisHub = try await APIService.shared.fetchAnalysisHub(ticker: ticker)
        } catch {
            print("Error loading Analysis Hub: \(error)")
            self.errorMessage = "Failed to load detailed analysis. Please check the backend integration."
        }
    }
}
