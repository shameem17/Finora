//
//  Colors.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI

enum CustomColor: String {
    case primaryBlue = "#007bff"
    case infoTeal = "#17a2b8"
    case successGreen = "#28a745"
    case warningYellow = "#ffc107"
    case dangerRed = "#dc3545"
    case darkGray = "#343a40"
    case secondaryGray = "#6c757d"
    case lightGray = "#f8f9fa"
    case customWhite = "#ffffff"
    
    case electricPurple = "#A259FF"
    case vividTeal = "#00BFA6"
    case warmCoral = "#FF6B6B"
    case amberYellow = "#FFB400"
    case royalAzure = "#006BDF"
    case midnightIndigo = "#040F49"
    case deepViolet = "#241446"
    case darkLavender = "#474787"
    case deepForestGreen = "#124622"
    case darkCyanSlate = "#0A2F30"
    
    var color: Color {
        Color(hex: self.rawValue)
    }
}

extension Color {
    
    static let appBackground = Color(hex: "#F5F0E6")
    static let customPurple = Color(hex: "#6900AA")
    static let customBlack = Color(hex: "#1C1E1F") //1C1E1F
    
    static let firstStepBackground = Color(hex: "#F5EAE5") //Color(hex: "#F0C3BC")
    static let secondStepBackground = Color(hex: "#F0F1E8")  //Color(hex: "#E8F3C9")
    static let thirdStepBackground = Color(hex: "F5EDE0")  //Color(hex: "#FFAB39").opacity(0.4)
    
    
    // MARK: - Brand Colors
    static let brandBlue = Color(hex: "#152ABE")
    static let brandWhite = Color(hex: "#FFFFFE")
    static let brandOrange = Color(hex: "#FFAB39")
    
    // MARK: - Gradient Colors
    static let blueGradientEnd = Color(hex: "#3548D0")
    static let whiteGradientEnd = Color(hex: "#F2F3F8")
    static let orangeGradientEnd = Color(hex: "#F89527")
    
    // MARK: - Background Gradients
    static let blueGradient = LinearGradient(
        colors: [.brandBlue, .blueGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let whiteGradient = LinearGradient(
        colors: [.brandWhite, .whiteGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [.brandOrange, .orangeGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension String{
    func toColor() -> Color {
        return Color(hex: self)
    }
}
