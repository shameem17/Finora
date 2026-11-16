//
//  CategoryModels.swift
//  Finora
//
//  Screens/Categories/Model
//

import Foundation

enum CategoryKind: String, PickerOption {
    case income = "Income"
    case expense = "Expense"

    var title: String { rawValue }

    var singular: String { rawValue.lowercased() }

    /// Curated SF Symbols offered in the icon picker.
    var icons: [String] {
        switch self {
        case .income:
            return ["banknote", "briefcase.fill", "laptopcomputer", "chart.line.uptrend.xyaxis",
                    "gift.fill", "building.columns.fill", "house.fill", "arrow.uturn.backward.circle.fill",
                    "percent", "star.fill", "person.2.fill", "storefront.fill",
                    "graduationcap.fill", "trophy.fill", "dollarsign.circle.fill", "tray.and.arrow.down.fill"]
        case .expense:
            return ["fork.knife", "cart.fill", "car.fill", "bus.fill",
                    "house.fill", "bolt.fill", "wifi", "iphone",
                    "cross.case.fill", "graduationcap.fill", "tshirt.fill", "film.fill",
                    "airplane", "gift.fill", "pawprint.fill", "dumbbell.fill",
                    "wrench.and.screwdriver.fill", "cup.and.saucer.fill", "gamecontroller.fill", "ellipsis.circle.fill"]
        }
    }
}

/// Named `TransactionCategory` to avoid clashing with the Objective-C `Category` type.
struct TransactionCategory: Identifiable, Hashable {
    let id: UUID
    var name: String
    let kind: CategoryKind
    /// SF Symbol name.
    var icon: String
    /// `#RRGGBB`.
    var tint: String
    /// Monthly budget; only meaningful for expense categories.
    var monthlyBudget: Double?

    init(id: UUID = UUID(),
         name: String,
         kind: CategoryKind,
         icon: String,
         tint: String,
         monthlyBudget: Double? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.icon = icon
        self.tint = tint
        self.monthlyBudget = kind == .expense ? monthlyBudget : nil
    }
}

extension TransactionCategory {

    static let defaults: [TransactionCategory] = [
        .init(name: "Salary", kind: .income, icon: "briefcase.fill", tint: "#28A745"),
        .init(name: "Freelance", kind: .income, icon: "laptopcomputer", tint: "#17A2B8"),
        .init(name: "Business", kind: .income, icon: "storefront.fill", tint: "#006BDF"),
        .init(name: "Gift", kind: .income, icon: "gift.fill", tint: "#A259FF"),
        .init(name: "Investment", kind: .income, icon: "chart.line.uptrend.xyaxis", tint: "#FFB400"),

        .init(name: "Food & Dining", kind: .expense, icon: "fork.knife", tint: "#FF6B6B", monthlyBudget: 8000),
        .init(name: "Groceries", kind: .expense, icon: "cart.fill", tint: "#28A745", monthlyBudget: 6000),
        .init(name: "Transport", kind: .expense, icon: "bus.fill", tint: "#006BDF", monthlyBudget: 3000),
        .init(name: "Bills & Utilities", kind: .expense, icon: "bolt.fill", tint: "#FFB400", monthlyBudget: 5000),
        .init(name: "Shopping", kind: .expense, icon: "tshirt.fill", tint: "#A259FF", monthlyBudget: 4000),
        .init(name: "Health", kind: .expense, icon: "cross.case.fill", tint: "#DC3545"),
        .init(name: "Entertainment", kind: .expense, icon: "film.fill", tint: "#00BFA6", monthlyBudget: 2000)
    ]
}
