import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = Environment.current.apiBaseURL
    private let decoder = JSONDecoder()
    
    enum APIError: Error {
        case unauthorized, forbidden, serverError, decodingError, networkIssue
    }

    private init() {
        // Configure decoder for snake_case (common in Python APIs) and ISO8601 dates
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    // Generalized request handler using Generics for type safety
    private func authenticatedRequest<T: Decodable>(path: String, method: String = "GET", body: Data? = nil) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // CRITICAL: Securely fetch the token via AuthService
        guard let token = AuthService.shared.getAuthToken() else {
            throw APIError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
             throw APIError.networkIssue
        }
        
        switch httpResponse.statusCode {
        case 200...299:
             do {
                 // Handle potentially empty responses (e.g., for POST/DELETE success)
                 if data.isEmpty, let emptyResponse = "{}".data(using: .utf8) {
                      return try decoder.decode(T.self, from: emptyResponse)
                 }
                 return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding Error: \(error)")
                throw APIError.decodingError
            }
        case 401:
            // Token invalid or expired. Force logout.
            AuthService.shared.logout() 
            throw APIError.unauthorized
        case 403:
            // Authenticated but subscription lapsed (SSRV failed on backend)
            // Update local subscription status
            DispatchQueue.main.async {
                SubscriptionManager.shared.isPremiumUser = false
            }
            throw APIError.forbidden
        default:
            throw APIError.serverError
        }
    }

    // --- Feature Endpoints ---

    func fetchDailyPicks() async throws -> [StockIdea] {
        return try await authenticatedRequest(path: "picks/daily")
    }
    
    func fetchPerformanceHistory() async throws -> [PerformanceRecord] {
        return try await authenticatedRequest(path: "picks/performance")
    }
    
    // Watchlist: Fetch all tickers
    func fetchWatchlist() async throws -> [String] {
        return try await authenticatedRequest(path: "watchlist")
    }
    
    // Define a simple success response structure for updates
    struct SuccessResponse: Decodable { let success: Bool? }

    // Watchlist: Add or Remove ticker
    func updateWatchlist(ticker: String, action: String) async throws {
        // Action must be 'add' or 'remove'
        let bodyDict = ["ticker": ticker, "action": action]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
        let _: SuccessResponse = try await authenticatedRequest(path: "watchlist", method: "POST", body: bodyData)
    }
}
