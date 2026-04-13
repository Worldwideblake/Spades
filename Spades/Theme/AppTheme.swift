import SwiftUI

enum AppTheme {
    // MARK: - Colors

    static let backgroundColor      = Color(hex: "#1A1D23")
    static let surfaceColor          = Color(hex: "#252830")
    static let overlayBackground     = Color(hex: "#2A2D35")
    static let badgeBackground       = Color(hex: "#2F323A")
    static let cardAreaBackground    = Color(hex: "#22252D")

    static let primaryText           = Color(hex: "#E8E9ED")
    static let secondaryText         = Color(hex: "#8B8F9A")
    static let accentColor           = Color(hex: "#4A9EFF")
    static let accentGreen           = Color(hex: "#34C759")
    static let warningColor          = Color(hex: "#FF6B6B")

    static let cardWhite             = Color(hex: "#F5F5F5")
    static let cardBack              = Color(hex: "#3A3D45")
    static let suitRed               = Color(hex: "#E55656")
    static let suitBlack             = Color(hex: "#2C2C2C")

    static let teamOneColor          = Color(hex: "#4A9EFF")
    static let teamTwoColor          = Color(hex: "#FF8A4A")

    // MARK: - Fonts

    static let headingFont           = Font.system(size: 22, weight: .bold, design: .rounded)
    static let subheadingFont        = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let playerNameFont        = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let captionFont           = Font.system(size: 11, weight: .medium, design: .rounded)
    static let tinyFont              = Font.system(size: 9, weight: .medium, design: .rounded)
    static let cardRankFont          = Font.system(size: 16, weight: .bold, design: .rounded)
    static let cardRankSmall         = Font.system(size: 10, weight: .bold, design: .rounded)
    static let suitSymbolLarge       = Font.system(size: 24, weight: .regular)
    static let bidNumberFont         = Font.system(size: 20, weight: .bold, design: .rounded)
    static let scoreFont             = Font.system(size: 28, weight: .bold, design: .rounded)

    // MARK: - Dimensions

    static let cardWidth: CGFloat    = 65
    static let cardHeight: CGFloat   = 95
    static let cardCorner: CGFloat   = 8
    static let miniCardWidth: CGFloat = 28
    static let miniCardHeight: CGFloat = 40
    static let badgeCorner: CGFloat  = 10
    static let overlayCorner: CGFloat = 20
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
