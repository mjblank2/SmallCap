import SwiftUI
import UIKit

struct StyleGuide {
    // MARK: - Color Palette (Dark Mode First, Trustworthy Blue/Positive Green)
    // Based on color psychology: Blue for trust/stability, Green for growth. High contrast for readability.
    struct ColorPalette {
        // Accent: Trustworthy Blue
        static let accent = Color(red: 60/255, green: 145/255, blue: 230/255)
        
        // Semantic Colors
        static let positive = Color(red: 40/255, green: 200/255, blue: 120/255) // Green for Gains
        static let negative = Color.red
        
        // Backgrounds (Deep, near-black for focus and reduced eye strain)
        static let backgroundMain = Color(red: 18/255, green: 20/255, blue: 28/255)
        static let backgroundCard = Color(red: 30/255, green: 33/255, blue: 45/255)
        
        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 180/255, green: 180/255, blue: 190/255)
    }
    
    // MARK: - Typography (SF Rounded for modern, friendly appeal)
    struct Typography {
        static let screenTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let sectionTitle = Font.system(size: 24, design: .rounded).weight(.bold)
        static let cardTitle = Font.system(size: 22, design: .rounded).weight(.bold)
        static let headline = Font.system(size: 17, design: .default).weight(.semibold)
        static let body = Font.system(size: 16, design: .default).weight(.regular)
    }
}

// Extensions for easy access (Used throughout the SwiftUI views)
extension Color {
    static let brandAccent = StyleGuide.ColorPalette.accent
    static let brandPositive = StyleGuide.ColorPalette.positive
    static let backgroundMain = StyleGuide.ColorPalette.backgroundMain
    static let backgroundCard = StyleGuide.ColorPalette.backgroundCard
    static let textPrimary = StyleGuide.ColorPalette.textPrimary
    static let textSecondary = StyleGuide.ColorPalette.textSecondary
}
