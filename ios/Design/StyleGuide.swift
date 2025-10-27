import SwiftUI

struct StyleGuide {
    // MARK: - Color Palette (Dark Mode First)
    // For production, define these in Assets.xcassets.
    struct ColorPalette {
        // Accent: Vibrant Emerald (Growth, Action)
        static let accent = Color(red: 10/255, green: 190/255, blue: 135/255)
        // Backgrounds (Near Black for high contrast and reduced eye strain)
        static let backgroundMain = Color(red: 18/255, green: 20/255, blue: 28/255)
        static let backgroundCard = Color(red: 30/255, green: 33/255, blue: 45/255)
        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
    }
    
    // MARK: - Typography (Using rounded design for modern appeal)
    struct Typography {
        static let title = Font.system(size: 24, weight: .bold, design: .rounded)
        static let cardTitle = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
    }
}

// Extension for easy access
extension Color {
    static let brandAccent = StyleGuide.ColorPalette.accent
    static let backgroundMain = StyleGuide.ColorPalette.backgroundMain
    static let backgroundCard = StyleGuide.ColorPalette.backgroundCard
}
