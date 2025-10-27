// ... inside APIService.swift ...

// Update the signature to include retryCount
private func authenticatedRequest<T: Decodable>(path: String, method: String = "GET", body: Data? = nil, retryCount: Int = 0) async throws -> T {
    
    // Ensure network is available before attempting request
    guard NetworkMonitor.shared.isConnected else {
        Log.reportError(APIError.networkIssue, context: "Network disconnected before request: \(path)")
        throw APIError.networkIssue
    }

    // ... (request setup remains the same) ...

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
             throw APIError.networkIssue
        }
        
        switch httpResponse.statusCode {
        case 200...299:
             // ... (decoding logic remains the same) ...
             return // ...
        case 401, 403:
            // ... (auth handling remains the same) ...
            throw // ...
        case 500...599:
            // Server errors might be transient. Implement retry logic (max 2 retries).
            if retryCount < 2 {
                Log.log("Server error \(httpResponse.statusCode). Retrying (\(retryCount + 1))...", level: .warning)
                // Exponential backoff (wait 1 second before retrying)
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return try await authenticatedRequest(path: path, method: method, body: body, retryCount: retryCount + 1)
            } else {
                Log.reportError(APIError.serverError, context: "Max retries reached for path: \(path)")
                throw APIError.serverError
            }
        default:
            Log.reportError(APIError.serverError, context: "Unexpected status code \(httpResponse.statusCode) for path: \(path)")
            throw APIError.serverError
        }
    } catch let error as DecodingError {
         Log.reportError(error, context: "Decoding failed for path: \(path)")
         throw APIError.decodingError
    } catch {
        // Catch network errors (e.g., timeouts)
        if let urlError = error as? URLError {
             Log.reportError(urlError, context: "URLSession error for path: \(path)")
             throw APIError.networkIssue
        }
        throw error // Re-throw other errors
    }
}
// ...
