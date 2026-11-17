//
//  SavingsSampleData.swift
//  Finora
//
//  Screens/Savings/Model
//

import Foundation

#if DEBUG
enum SavingsSampleData {
    static func savings(accounts: [Account]) -> [SavingsAccount] {
        guard let bank = accounts.first(where: { $0.type == .bank }) ?? accounts.first else { return [] }
        let cal = Calendar.current
        let start = cal.date(byAdding: .month, value: -5, to: .now) ?? .now

        let emergency = SavingsAccount(
            name: "\(bank.name) Savings",
            accountID: bank.id,
            tint: bank.tint,
            startDate: start,
            target: 200_000,
            targetDate: cal.date(byAdding: .month, value: 8, to: .now),
            note: "Emergency fund",
            openingBalance: 20_000,
            entries: [
                SavingsEntry(kind: .deposit, amount: 15_000, date: cal.date(byAdding: .month, value: -3, to: .now) ?? .now, account: AccountSummary(bank)),
                SavingsEntry(kind: .deposit, amount: 25_000, date: cal.date(byAdding: .month, value: -1, to: .now) ?? .now, account: AccountSummary(bank)),
                SavingsEntry(kind: .withdrawal, amount: 5_000, date: cal.date(byAdding: .day, value: -10, to: .now) ?? .now, note: "Medical", account: AccountSummary(bank))
            ]
        )
        return [emergency]
    }
}
#endif
