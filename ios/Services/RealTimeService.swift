import Foundation
import Combine

class RealTimeService: ObservableObject {
    static let shared = RealTimeService()
    @Published var livePrices: [String: Double] = [:]
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    enum ConnectionStatus { case disconnected, connecting, connected, failed }

    private var webSocketTask: URLSessionWebSocketTask?
    private var polygonToken: String?
    
    // Connect is async as it requires the secure token first
    func connect() async {
        guard connectionStatus == .disconnected || connectionStatus == .failed else { return }
        
        // 1. Securely Fetch Token from Backend
        DispatchQueue.main.async { self.connectionStatus = .connecting }
        do {
            // This ensures only subscribed users access the token.
            self.polygonToken = try await APIService.shared.fetchRealtimeToken()
        } catch {
            print("Security Check Failed: Cannot fetch Real-Time Token. \(error)")
            DispatchQueue.main.async { self.connectionStatus = .failed }
            return
        }
        
        // 2. Establish WebSocket Connection (Polygon)
        let url = URL(string: "wss://socket.polygon.io/stocks")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // 3. Start listening and authenticate
        receiveMessages()
        authenticate()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        DispatchQueue.main.async { self.connectionStatus = .disconnected }
    }
    
    private func authenticate() {
        guard let token = polygonToken else { return }
        let authMessage = "{\"action\":\"auth\",\"params\":\"\(token)\"}"
        sendMessage(authMessage)
    }
    
    func subscribe(to tickers: [String]) {
        guard !tickers.isEmpty, connectionStatus == .connected else { return }
        // Subscribe to the "Q" (Quote) stream for NBBO updates
        let subscriptionMessage = "{\"action\":\"subscribe\",\"params\":\"Q.\(tickers.joined(separator: ",Q." ))\"}"
        sendMessage(subscriptionMessage)
    }
    
    private func sendMessage(_ message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error { print("WebSocket send error: \(error)") }
        }
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket error: \(error)")
                DispatchQueue.main.async { self?.connectionStatus = .failed }
                // Implement reconnection logic here
            case .success(let message):
                if case .string(let text) = message {
                    self?.processMessage(text)
                }
                // Continue listening
                if self?.webSocketTask != nil {
                    self?.receiveMessages()
                }
            }
        }
    }
    
    private func processMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                for item in jsonArray {
                    // Handle Status Messages (Authentication Confirmation)
                    if item["ev"] as? String == "status" {
                        let status = item["status"] as? String
                        if status == "auth_success" {
                            DispatchQueue.main.async { self?.connectionStatus = .connected }
                        }
                    }
                    
                    // Process Quote messages ("ev": "Q")
                    if item["ev"] as? String == "Q",
                       let ticker = item["sym"] as? String,
                       // Use bid price "p" or ask price "P" depending on preference
                       let price = item["p"] as? Double { 
                        
                        DispatchQueue.main.async {
                            self?.livePrices[ticker] = price
                        }
                    }
                }
            }
        } catch {
            print("WebSocket JSON parsing error: \(error)")
        }
    }
}
