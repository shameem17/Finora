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
    let button: OnboardinButton
    let shortNote: String
}

enum OnboardinButton{
    case next, getStarted
    
    var title: String {
        switch self {
        case .next:
            return "Next ->"
        case .getStarted:
            return "Get Started"
        }
    }
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
                titleColor: .customBlack,
                descriptionColor: Color(hex: "#1C1E1F"),
                button: .next,
                shortNote: "Your financial journey\nstarts here"
            )

        case .second:
            return OnboardingModel(
                id: 2,
                title: "Plan Today",
                description: "Manage your budgets, loans, savings and financial goals in one place. Build better money habits and achieve your dreams.",
                imageName: "onboardSecond",
                bgcolorCode: Color.secondStepBackground,
                titleColor: .customBlack,
                descriptionColor: Color(hex: "#1C1E1F"),
                button: .next,
                shortNote: "Budget, save, and plan your\nfinancial future with ease"
            )

        case .third:
            return OnboardingModel(
                id:3,
                title: "Your Privacy",
                description: "Your financial information stays on your device. No account, no internet connection, and no cloud storage required.",
                imageName: "onboardThird",
                bgcolorCode: Color.thirdStepBackground,
                titleColor: .customBlack,
                descriptionColor: Color(hex: "#1C1E1F"),
                button: .getStarted,
                shortNote: "Your privacy is our priority.\nYour data stays with you"
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

