import Foundation
import Combine

// Manages the global state of the user's watchlist using a shared instance (Singleton pattern)
@MainActor
class WatchlistViewModel: ObservableObject {
    static let shared = WatchlistViewModel()
    
    // The set of tickers the user is watching
    @Published var watchedTickers: Set<String> = []
    
    private var authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Observe authentication state changes
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    // Load watchlist when user logs in
                    Task { await self?.loadWatchlist() }
                } else {
                    // Clear watchlist when user logs out
                    self?.watchedTickers = []
                }
            }
            .store(in: &cancellables)
    }

    func loadWatchlist() async {
        guard authService.isAuthenticated else { return }
        do {
            let tickers = try await APIService.shared.fetchWatchlist()
            self.watchedTickers = Set(tickers)
        } catch {
            print("Error loading watchlist: \(error)")
        }
    }

    func toggleWatchlist(ticker: String) async {
        let isCurrentlyWatched = watchedTickers.contains(ticker)
        let action = isCurrentlyWatched ? "remove" : "add"

        // Optimistic UI update (Update UI immediately for responsiveness)
        if isCurrentlyWatched {
            watchedTickers.remove(ticker)
        } else {
            watchedTickers.insert(ticker)
        }
        
        do {
            try await APIService.shared.updateWatchlist(ticker: ticker, action: action)
        } catch {
            // Rollback if the API call fails
            print("Error updating watchlist: \(error). Rolling back.")
            if isCurrentlyWatched {
                watchedTickers.insert(ticker)
            } else {
                watchedTickers.remove(ticker)
            }
            // Notify user of failure
        }
    }
    
    func isWatching(_ ticker: String) -> Bool {
        return watchedTickers.contains(ticker)
    }
}
