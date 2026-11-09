//
//  AppTab.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//


import SwiftUI


enum AppTab: Hashable, CaseIterable, Identifiable {

    case home, income, expense, transaction, loan, settings

    var id: Self { self }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        case .transaction:
            return "Transactions"
        case .loan:
            return "Loans"
        case .settings:
            return "Settings"
        }
    }

    var unselectedtabBarImage: String {
        switch self {
        case .home:
            return "house"
        case .income:
            return "arrow.down.left.circle"
        case .expense:
            return "arrow.up.right.circle"
        case .transaction:
            return "list.bullet.rectangle"
        case .loan:
            return "banknote"
        case .settings:
            return "gearshape"
        }
    }

    var selectedtabBarImage: String {
        return unselectedtabBarImage + ".fill"
    }

    func coordinator(
        settings: AppSettings
    ) -> Coordinator {

        switch self {
        case .home:
            return HomeCoordinator(settings: settings)

        case .income:
            return IncomeCoordinator(settings: settings)

        case .expense:
            return ExpenseCoordinator(settings: settings)

        case .transaction:
            return TransactionCoordinator(settings: settings)

        case .loan:
            return LoanCoordinator(settings: settings)

        case .settings:
            return SettingsCoordinator(settings: settings)
        }
    }
}
