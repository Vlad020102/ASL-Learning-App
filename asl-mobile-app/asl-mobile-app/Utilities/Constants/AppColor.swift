import SwiftUI

struct AppColors {
    // Main colors
    static let primary = Color(hex: "d24631")
    static let secondary = Color(hex: "61709c")
    
    // Accent colors
    static let accent1 = Color(hex: "f23c4c")
    static let accent2 = Color(hex: "2c2c44")
    static let accent3 = Color(hex: "bfbbd9")
    
    // Base colors
    static let background = Color(hex: "bfbbd9")
    static let card = Color.white
    static let text = Color(hex: "333333")
    static let textSecondary = Color(hex: "2c2c44")
    static let border = Color(hex: "E5E5EA")
    
    // Feedback colors
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "af1010")
    static let error = Color(hex: "FF3B30")
    
    // Interaction colors
    static let selectedBackground = primary.opacity(0.1)
    static let disabledBackground = Color(hex: "E5E5EA")
    static let disabledText = Color(hex: "C7C7CC")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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
