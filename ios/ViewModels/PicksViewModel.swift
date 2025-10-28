import Foundation
import Combine

@MainActor // Ensures all UI updates happen on the main thread
class PicksViewModel: ObservableObject {
    enum ViewState { case loading, loaded, error(String) }
    @Published var state: ViewState = .loading
    @Published var ideas: [StockIdea] = []
    
    // ViewModel relies on the AppRootView/MainTabView to handle subscription checks before displaying the view.
    func loadPicks() async {
        // Avoid reloading state flicker if data already exists
        if ideas.isEmpty { state = .loading }
        
        do {
            let fetchedIdeas = try await APIService.shared.fetchDailyPicks()
            self.ideas = fetchedIdeas
            self.state = .loaded
        } catch {
            Log.reportError(error, context: "loadPicks failed")
            // Provide user-friendly error messages
            self.state = .error("Failed to load picks. Error: \(error.localizedDescription)")
        }
    }
}
