//
//  OnboardingModel.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation

struct OnboardingModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let bgcolorCode: String
}

enum OnboardingStep: Int, CaseIterable {
    case first
    case second
    case third

    var model: OnboardingModel {
        switch self {

        case .first:
            return OnboardingModel(
                title: "Take Control of Your Money",
                description: """
                Track every income and expense effortlessly.
                Understand where your money goes and make
                smarter financial decisions every day.
                """,
                imageName: "chart.pie.fill",
                bgcolorCode: "#F0C3BC"
            )

        case .second:
            return OnboardingModel(
                title: "Plan Today. Save for Tomorrow.",
                description: """
                Manage your budgets, loans, savings and
                financial goals in one place. Build better
                money habits and achieve your dreams.
                """,
                imageName: "chart.line.uptrend.xyaxis",
                bgcolorCode: "#E8F3C9"
            )

        case .third:
            return OnboardingModel(
                title: "Your Money. Your Data. Your Privacy.",
                description: """
                Your financial information stays on your
                device. No account, no internet connection,
                and no cloud storage required.
                """,
                imageName: "lock.shield.fill",
                bgcolorCode: "#F6D0B5"
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
