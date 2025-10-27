import Foundation

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [EventCatalyst] = []
    @Published var isLoading: Bool = false
    
    func loadEvents() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch events using the updated APIService
            let fetchedEvents = try await APIService.shared.fetchLatestEvents()
            // Sort by date descending
            self.events = fetchedEvents.sorted(by: { $0.date > $1.date })
        } catch {
            // In production: Use LoggerService to report the error
            print("Failed to load events feed: \(error)")
            // Handle error state (e.g., show an alert or empty state message)
        }
    }
}
