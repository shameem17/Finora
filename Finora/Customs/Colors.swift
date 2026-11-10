//
//  Colors.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI

extension Color {
    
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

