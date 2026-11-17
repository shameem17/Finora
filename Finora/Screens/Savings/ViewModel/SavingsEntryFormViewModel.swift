//
//  SavingsEntryFormViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//

import Foundation
import Observation

@Observable
final class SavingsEntryFormViewModel: Identifiable {

    let id = UUID()
    let kind: SavingsEntryKind
    let savings: SavingsAccount
    let accounts: [Account]

    var accountID: Account.ID?
    var amountText = ""
    var date: Date = .now
    var note = ""

    @ObservationIgnored private let dependencies: SavingsDependencies

    init(kind: SavingsEntryKind, savings: SavingsAccount, dependencies: SavingsDependencies) {
        self.kind = kind
        self.savings = savings
        self.dependencies = dependencies
        self.accounts = dependencies.accounts.fetchAccounts()
        self.accountID = accounts.contains { $0.id == savings.accountID } ? savings.accountID : accounts.first?.id
    }

    var amount: Double { DecimalInput.value(of: amountText) }
    var account: Account? { accounts.first { $0.id == accountID } }
    var current: Double { savings.currentSavings }

    var earliestDate: Date { Calendar.current.startOfDay(for: savings.startDate) }

    /// Savings left after this entry.
    var savingsAfter: Double? {
        guard amount > 0 else { return nil }
        return kind == .deposit ? current + amount : current - amount
    }

    /// Chosen account's balance after this entry.
    var balanceAfter: Double? {
        guard amount > 0, let account else { return nil }
        return kind == .deposit ? account.balance - amount : account.balance + amount
    }

    var visibleError: String? {
        guard amount > 0 else { return nil }
        switch kind {
        case .deposit:
            if let account, amount > account.balance + 0.005 {
                return "Not enough balance. Available: \(CurrencyFormatter.taka(account.balance, showFraction: true))"
            }
        case .withdrawal:
            if amount > current + 0.005 {
                return "That's more than you have saved: \(CurrencyFormatter.taka(current, showFraction: true))"
            }
        }
        return nil
    }

    var canSubmit: Bool { amount > 0 && account != nil && visibleError == nil }

    func withdrawAll() { amountText = Self.text(current) }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit, let account else { return false }

        let entry = SavingsEntry(kind: kind, amount: amount, date: date,
                                 note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                                 account: AccountSummary(account))
        switch kind {
        case .deposit:    dependencies.service.deposit(entry, to: savings.id)
        case .withdrawal: dependencies.service.withdraw(entry, from: savings.id)
        }
        return true
    }

    private static func text(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(format: "%.2f", value)
    }
}
