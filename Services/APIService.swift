import Foundation

class APIService {
    static let shared = APIService()
    // In production, replace with your deployed backend URL (HTTPS)
    // For local testing against the Python script:
    private let baseURL = URL(string: "http://127.0.0.1:5001/api/v1")!
    private let decoder = JSONDecoder()
    
    enum APIError: Error {
        case unauthorized, serverError, decodingError
    }

    private init() {
        // The backend uses ISO8601 dates (Crucial for correct parsing)
        decoder.dateDecodingStrategy = .iso8601
    }

    func fetchDailyPicks() async throws -> [StockIdea] {
        let url = baseURL.appendingPathComponent("picks/daily")
        var request = URLRequest(url: url)
        
        // CRITICAL: In production, fetch the user's auth token securely from Keychain
        // (e.g., JWT or OAuth token) and add it as a Bearer token.
        // request.setValue("Bearer <TOKEN>", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
             throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                 return try decoder.decode([StockIdea].self, from: data)
            } catch {
                print("Decoding Error: \(error)")
                throw APIError.decodingError
            }
        case 401, 403:
            // Handle Unauthorized/Unsubscribed state
            throw APIError.unauthorized
        default:
            throw APIError.serverError
        }
    }
}
