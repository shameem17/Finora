//
//  FinanceOverview.swift
//  Finora
//
//  Screens/Home/Model
//
//  The "where do I stand" numbers shown on Home, across every feature.
//

import Foundation

struct FinanceOverview: Equatable {

    /// Sum of every account balance.
    var accountsTotal = 0.0
    var accountCount = 0

    /// Loans still to be collected from other people.
    var toCollect = 0.0
    /// Money borrowed that is still to be paid back.
    var toRepay = 0.0

    /// Money set aside in savings goals.
    var savings = 0.0
    var savingsCount = 0

    /// Income minus expense this month.
    var monthBalance = 0.0

    /// Accounts plus what is owed to you, minus what you owe.
    /// Savings are excluded: deposits already move account balances.
    var netWorth: Double { accountsTotal + toCollect - toRepay }

    static let empty = FinanceOverview()
}

extension FinanceOverview {

    static func make(accounts: [Account],
                     loans: [Loan],
                     savings: [SavingsAccount],
                     monthBalance: Double) -> FinanceOverview {
        var overview = FinanceOverview()
        overview.accountsTotal = accounts.reduce(0) { $0 + $1.balance }
        overview.accountCount = accounts.count
        overview.savings = savings.reduce(0) { $0 + $1.currentSavings }
        overview.savingsCount = savings.count
        overview.monthBalance = monthBalance

        for loan in loans where !loan.isSettled {
            if loan.kind == .lent { overview.toCollect += loan.outstanding }
            else { overview.toRepay += loan.outstanding }
        }
        return overview
    }
}
