import Foundation
import Network
import Combine

// Monitors the network connection status in real-time
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let status = (path.status == .satisfied)
                if status != self?.isConnected {
                    Log.log("Network status changed: \(status ? "Connected" : "Disconnected")", level: .info)
                    self?.isConnected = status
                }
            }
        }
        monitor.start(queue: queue)
    }
}
