import Foundation
import Combine

@MainActor // Ensures UI updates happen safely on the main thread
class PicksViewModel: ObservableObject {
    enum ViewState {
        case loading, loaded, error(String)
    }

    @Published var state: ViewState = .loading
    @Published var ideas: [StockIdea] = []
    
    // Depend on the SubscriptionManager
    @Published var isSubscribed: Bool = false
    private var subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()

    private let apiService: APIService

    init(apiService: APIService = .shared, subscriptionManager: SubscriptionManager = .shared) {
        self.apiService = apiService
        self.subscriptionManager = subscriptionManager
        
        // Observe changes in subscription status dynamically
        subscriptionManager.$isPremiumUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPremium in
                // If the status changes, update the ViewModel
                self?.isSubscribed = isPremium
                if isPremium {
                    // If newly subscribed (or app launched while subscribed), load the picks
                    Task { await self?.loadPicks() }
                } else {
                    // If unsubscribed, clear the data
                    self?.ideas = []
                    self?.state = .loaded // State is loaded, but UI will show Paywall
                }
            }
            .store(in: &cancellables)
    }

    func loadPicks() async {
        // Do not attempt to load if the manager knows the user isn't subscribed
        guard subscriptionManager.isPremiumUser else { return }
        
        // Avoid reloading state flicker if data already exists
        if ideas.isEmpty {
            state = .loading
        }
        
        do {
            let fetchedIdeas = try await apiService.fetchDailyPicks()
            self.ideas = fetchedIdeas
            self.state = .loaded
        } catch APIService.APIError.unauthorized {
            // If the API returns 401/403, the subscription might have lapsed on the backend
            self.state = .error("Subscription required.")
            // Update the subscription manager to reflect the backend reality
            DispatchQueue.main.async {
                self.subscriptionManager.isPremiumUser = false
            }
        } catch {
            print("Error fetching picks: \(error)")
            self.state = .error("Failed to load data. Check connection and ensure the backend server is running.")
        }
    }
}
