// iOS/Services/APIService.swift (Excerpt)

class APIService {
    // ... (Existing properties and init) ...
    
    // Initialize a specific DateFormatter for Tiingo fundamental dates (YYYY-MM-DD)
    private let tiingoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    // Generalized request handler (Update to handle dynamic date strategies)
    private func authenticatedRequest<T: Decodable>(path: String, method: String = "GET", body: Data? = nil, dateStrategy: JSONDecoder.DateDecodingStrategy? = nil) async throws -> T {
        
        // ... (Request setup, Authentication) ...
        // Use the configured session (assuming caching setup from previous iterations)
        let (data, response) = try await self.session.data(for: request)

        // ... (Response status code handling: 401, 403, 500s) ...

        // Use a local decoder instance for flexibility
        let requestDecoder = JSONDecoder()
        requestDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Use the specified date strategy, or default to ISO8601
        requestDecoder.dateDecodingStrategy = dateStrategy ?? .iso8601

        // Decoding (within the 200-299 case)
        return try requestDecoder.decode(T.self, from: data)
    }

    // --- New Feature Endpoints ---

    func fetchAnalysisHub(ticker: String) async throws -> AnalysisHub {
        // This endpoint contains dates in the Tiingo format within the 'fundamentalsChart' array.
        return try await authenticatedRequest(
            path: "analysis/hub/\(ticker)",
            // Apply the specific formatter for this request
            dateStrategy: .formatted(tiingoDateFormatter)
        )
    }
    
    // NEW: Securely fetch the Polygon token
    func fetchRealtimeToken() async throws -> String {
        struct TokenResponse: Decodable { let token: String }
        // This request must be authenticated to ensure the user is subscribed
        let response: TokenResponse = try await authenticatedRequest(path: "config/realtime_token")
        return response.token
    }
}
