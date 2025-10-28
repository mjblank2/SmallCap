import SwiftUI
import UIKit // Import UIKit for Haptics

struct StyleGuide {
    // MARK: - Color Palette (Trust & Professionalism)
    struct ColorPalette {
        // Accent: Trustworthy Blue (Calm, Stability)
        static let accent = Color(red: 60/255, green: 145/255, blue: 230/255)
        
        // Semantic Colors
        static let positive = Color(red: 40/255, green: 200/255, blue: 120/255) // Green for Gains
        static let negative = Color.red
        
        // Backgrounds (Deep, near-black for focus)
        static let backgroundMain = Color(red: 18/255, green: 20/255, blue: 28/255)
        static let backgroundCard = Color(red: 30/255, green: 33/255, blue: 45/255)
        
        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 180/255, green: 180/255, blue: 190/255)
    }
    
    // MARK: - Typography (Clarity and Friendliness)
    struct Typography {
        // Using rounded design for a modern, friendly feel.
        static let screenTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let sectionTitle = Font.system(size: 24, design: .rounded).weight(.bold)
        static let cardTitle = Font.system(size: 22, design: .rounded).weight(.bold)
        static let headline = Font.system(size: 17, design: .default).weight(.semibold)
        static let body = Font.system(size: 16, design: .default).weight(.regular)
        static let caption = Font.system(size: 12, design: .default).weight(.medium)
    }
}

// Extension for easy access
extension Color {
    static let brandAccent = StyleGuide.ColorPalette.accent
    static let brandPositive = StyleGuide.ColorPalette.positive
    static let backgroundMain = StyleGuide.ColorPalette.backgroundMain
    static let backgroundCard = StyleGuide.ColorPalette.backgroundCard
    static let textPrimary = StyleGuide.ColorPalette.textPrimary
    static let textSecondary = StyleGuide.ColorPalette.textSecondary
}

// MARK: - Haptics Manager (Delight and Feedback)
class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    func impactLight() {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    func notifySuccess() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    func notifyWarning() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}
// Convenience wrapper
var Haptics = HapticsManager.shared
