// iOS/Services/APIService.swift (Complete File)
import Foundation

class APIService {
    static let shared = APIService()
    // Use the Environment config
    private let baseURL = Environment.current.apiBaseURL
    
    // Configure a session (e.g., for caching)
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()

    // Initialize a specific DateFormatter for Tiingo fundamental dates (YYYY-MM-DD)
    private let tiingoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    // Generalized request handler
    private func authenticatedRequest<T: Decodable>(path: String, method: String = "GET", body: Data? = nil, dateStrategy: JSONDecoder.DateDecodingStrategy? = nil) async throws -> T {
        
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add auth token from Keychain
        if let token = KeychainHelper.shared.get(account: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
             // If no token, and it's not a login request, fail fast
             // (You would add a check here if the path wasn't login)
             print("Warning: No auth token found for request to \(path)")
        }
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await self.session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid server response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Use a local decoder instance for flexibility
            let requestDecoder = JSONDecoder()
            requestDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Use the specified date strategy, or default to ISO8601
            requestDecoder.dateDecodingStrategy = dateStrategy ?? .iso8601

            do {
                return try requestDecoder.decode(T.self, from: data)
            } catch {
                Log.reportError(error, context: "APIService decoding error for \(path)")
                throw APIError.decodingError(error)
            }
        case 401, 403:
            Log.log("Authentication error (401/403). Logging out.", level: .warning)
            // Broadcast an authentication failure
            await AuthService.shared.logout()
            throw APIError.unauthorized
        default:
            Log.log("Server error: \(httpResponse.statusCode) for \(path)", level: .error)
            throw APIError.serverError("Server returned code \(httpResponse.statusCode)")
        }
    }
    
    // Helper for requests that don't need a decoded response
    private func authenticatedRequestNoResponse(path: String, method: String, body: Data? = nil) async throws {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = KeychainHelper.shared.get(account: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } // else... (handle auth error)
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (_, response) = try await self.session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid server response")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401, 403:
            Log.log("Authentication error (401/403). Logging out.", level: .warning)
            await AuthService.shared.logout()
            throw APIError.unauthorized
        default:
            Log.log("Server error: \(httpResponse.statusCode) for \(path)", level: .error)
            throw APIError.serverError("Server returned code \(httpResponse.statusCode)")
        }
    }

    // --- Public API Methods ---

    // (Existing methods: fetchDailyPicks, fetchPerformanceHistory, fetchWatchlist, updateWatchlist, fetchLatestEvents)
    // ...

    func fetchAnalysisHub(ticker: String) async throws -> AnalysisHub {
        return try await authenticatedRequest(
            path: "analysis/hub/\(ticker)",
            dateStrategy: .formatted(tiingoDateFormatter)
        )
    }
    
    func fetchRealtimeToken() async throws -> String {
        struct TokenResponse: Decodable { let token: String }
        let response: TokenResponse = try await authenticatedRequest(path: "config/realtime_token")
        return response.token
    }
    
    // --- GAP 1 Fix: Register Device Token ---
    func registerDeviceToken(_ token: String) async {
        struct TokenPayload: Codable { let token: String }
        let payload = TokenPayload(token: token)
        
        do {
            let data = try JSONEncoder().encode(payload)
            try await authenticatedRequestNoResponse(
                path: "user/register_device",
                method: "POST",
                body: data
            )
            Log.log("Device token registered successfully", level: .info)
        } catch {
            Log.reportError(error, context: "Failed to register device token")
        }
    }
    
    // --- GAP 2 Fix: Delete Account ---
    func deleteAccount() async throws {
        try await authenticatedRequestNoResponse(
            path: "user/account",
            method: "DELETE"
        )
        Log.log("Account deletion request sent successfully", level: .info)
    }
}

// --- Error Enum ---
enum APIError: Error {
    case unauthorized
    case serverError(String)
    case decodingError(Error)
}

