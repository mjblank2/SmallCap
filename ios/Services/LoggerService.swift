import Foundation
// In production: import Sentry or import FirebaseCrashlytics

class LoggerService {
    static let shared = LoggerService()
    
    enum LogLevel: String {
        case info, warning, error, debug
    }
    
    func log(_ message: String, level: LogLevel = .debug, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logOutput = "[\(level.rawValue.uppercased())] \(fileName):\(line) - \(message)"
        
        #if DEBUG
        print(logOutput)
        #endif
        
        // In production: Send critical logs to centralized platform (e.g., Sentry.capture(message: logOutput))
    }
    
    func reportError(_ error: Error, context: String? = nil) {
        let errorMessage = "Non-fatal Error Reported: \(error.localizedDescription). Context: \(context ?? "N/A")"
        log(errorMessage, level: .error)
        // In production: E.g., Crashlytics.crashlytics().record(error: error)
    }
}
// Convenience wrapper
var Log = LoggerService.shared
