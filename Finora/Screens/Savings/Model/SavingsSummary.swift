//
//  SavingsSummary.swift
//  Finora
//
//  Screens/Savings/Model
//

import Foundation

struct SavingsBreakdownRow: Identifiable, Equatable {
    let id: Account.ID
    let name: String
    let tint: String
    let type: AccountType
    let amount: Double
    /// 0...1 share of all savings.
    let share: Double
    let count: Int
}

struct SavingsSummary: Equatable {
    let totalSavings: Double
    let totalTarget: Double
    let totalDeposited: Double
    let totalWithdrawn: Double
    let count: Int
    let goalsReached: Int
    let breakdown: [SavingsBreakdownRow]

    static let empty = SavingsSummary(totalSavings: 0, totalTarget: 0, totalDeposited: 0,
                                      totalWithdrawn: 0, count: 0, goalsReached: 0, breakdown: [])

    /// Overall progress towards the combined target; `nil` when no target is set.
    var progress: Double? {
        totalTarget > 0 ? min(totalSavings / totalTarget, 1) : nil
    }

    static func make(savings: [SavingsAccount], accounts: [Account]) -> SavingsSummary {
        let total = savings.reduce(0) { $0 + $1.currentSavings }

        let grouped = Dictionary(grouping: savings, by: \.accountID)
        let rows: [SavingsBreakdownRow] = grouped.compactMap { id, group in
            guard let account = accounts.first(where: { $0.id == id }) else { return nil }
            let amount = group.reduce(0) { $0 + $1.currentSavings }
            return SavingsBreakdownRow(id: id, name: account.name, tint: account.tint, type: account.type,
                                       amount: amount, share: total > 0 ? amount / total : 0,
                                       count: group.count)
        }
        .sorted { $0.amount > $1.amount }

        return SavingsSummary(
            totalSavings: total,
            totalTarget: savings.reduce(0) { $0 + ($1.target ?? 0) },
            totalDeposited: savings.reduce(0) { $0 + $1.totalDeposited },
            totalWithdrawn: savings.reduce(0) { $0 + $1.totalWithdrawn },
            count: savings.count,
            goalsReached: savings.filter(\.isGoalReached).count,
            breakdown: rows
        )
    }
}
