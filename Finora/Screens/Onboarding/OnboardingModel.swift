//
//  OnboardingModel.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation

import SwiftUI

struct OnboardingModel: Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
    let bgcolorCode: Color
    let titleColor: Color
    let descriptionColor: Color
    let buttonTitle: String
}

enum OnboardingStep: Int, CaseIterable {
    case first
    case second
    case third

    var model: OnboardingModel {
        switch self {

        case .first:
            return OnboardingModel(
                id: 1,
                title: "Take Control",
                description: "Track every income and expense effortlessly. Understand where your money goes and make smarter financial decisions every day.",
                imageName: "onboardFirst",
                bgcolorCode: Color.firstStepBackground,
                titleColor: Color(hex: "#1C1E1F"),
                descriptionColor: Color(hex: "#1C1E1F"), buttonTitle: "Next ->"
            )

        case .second:
            return OnboardingModel(
                id: 2,
                title: "Plan Today",
                description: "Manage your budgets, loans, savings and financial goals in one place. Build better money habits and achieve your dreams.",
                imageName: "onboardSecond",
                bgcolorCode: Color.secondStepBackground,
                titleColor: Color(hex: "#1C1E1F"),
                descriptionColor: Color(hex: "#1C1E1F"), buttonTitle: "Next ->"
            )

        case .third:
            return OnboardingModel(
                id:3,
                title: "Your Privacy",
                description: "Your financial information stays on your device. No account, no internet connection, and no cloud storage required.",
                imageName: "onboardThird",
                bgcolorCode: Color.thirdStepBackground,
                titleColor: Color(hex: "#1C1E1F"),
                descriptionColor: Color(hex: "#1C1E1F"),
                buttonTitle: "Get Started"
            )
        }
    }

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }

    var isLast: Bool {
        self == .third
    }
}

extension Color {
    
    static let firstStepBackground = Color(hex: "#F0C3BC")
    static let secondStepBackground = Color(hex: "#E8F3C9")
    static let thirdStepBackground = Color(hex: "#FFAB39").opacity(0.4)
    

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

