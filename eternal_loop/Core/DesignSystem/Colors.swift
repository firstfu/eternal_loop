//
//  Colors.swift
//  eternal_loop
//

import SwiftUI

extension Color {
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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

// MARK: - App Colors
extension Color {
    // Primary - Romantic Violet
    static let appPrimary = Color(hex: "#7C3AED")
    static let appPrimaryLight = Color(hex: "#A78BFA")
    static let appPrimaryDark = Color(hex: "#4C1D95")

    // Accent - Rose Gold
    static let appAccent = Color(hex: "#F9A8D4")
    static let appAccentGold = Color(hex: "#D4AF37")

    // Background
    static let appBackgroundDark = Color(hex: "#0F0A1A")
    static let appBackgroundLight = Color(hex: "#FAF5FF")

    // Text
    static let appTextPrimary = Color.white.opacity(0.95)
    static let appTextSecondary = Color.white.opacity(0.7)

    // Effects
    static let heartbeatGlow = Color(hex: "#FF6B9D")
    static let particleGold = Color(hex: "#FFD700")
}
