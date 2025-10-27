import Foundation

// Manages environment switching (Dev/Staging/Prod)
enum Environment {
    // In a production project, use Xcode Build Configurations and .xcconfig files 
    // to manage this automatically. For this example, we manually set it.
    static var current: Configuration = .development
    
    enum Configuration {
        case development, production
        
        var apiBaseURL: URL {
            switch self {
            // Local testing against the Python backend
            case .development: return URL(string: "http://127.0.0.1:5001/api/v1")!
            // Real deployed backend (HTTPS required by Apple's App Transport Security)
            case .production: return URL(string: "https://api.yourdomain.com/api/v1")!
            }
        }
    }
}
