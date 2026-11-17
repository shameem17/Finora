//
//  SavingsEntryFormViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//
//  One form for adding savings, withdrawing (breaking savings) and editing an
//  existing entry. Linking an account is optional, so money saved or taken out
//  elsewhere can still be recorded without touching any balance.
//

import Foundation
import Observation

@Observable
final class SavingsEntryFormViewModel: Identifiable {

    enum Mode {
        case create(SavingsEntryKind)
        case edit(SavingsEntry)
    }

    let id = UUID()
    let mode: Mode
    let kind: SavingsEntryKind
    let savings: SavingsAccount
    let accounts: [Account]

    /// Whether an account balance is adjusted along with this entry.
    var usesAccount: Bool
    var accountID: Account.ID?
    var amountText = ""
    var date: Date = .now
    var note = ""

    @ObservationIgnored private let dependencies: SavingsDependencies

    init(mode: Mode, savings: SavingsAccount, dependencies: SavingsDependencies) {
        self.mode = mode
        self.savings = savings
        self.dependencies = dependencies
        self.accounts = dependencies.accounts.fetchAccounts()

        let fallback = accounts.contains { $0.id == savings.accountID } ? savings.accountID : accounts.first?.id

        switch mode {
        case .create(let kind):
            self.kind = kind
            usesAccount = fallback != nil
            accountID = fallback
        case .edit(let entry):
            kind = entry.kind
            usesAccount = entry.account != nil
            accountID = entry.account?.id ?? fallback
            amountText = DecimalInput.text(entry.amount)
            date = entry.date
            note = entry.note
        }
    }

    // MARK: Derived

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { isEditing ? "Edit \(kind.historyTitle)" : kind.title }
    var saveTitle: String { isEditing ? "Save Changes" : kind.title }

    private var editingEntry: SavingsEntry? {
        if case .edit(let entry) = mode { return entry }
        return nil
    }

    var amount: Double { DecimalInput.value(of: amountText) }
    var account: Account? { usesAccount ? accounts.first { $0.id == accountID } : nil }

    /// Savings as they would be without the entry being edited.
    private var baseSavings: Double {
        guard let old = editingEntry else { return savings.totalDeposited - savings.totalWithdrawn }
        return savings.totalDeposited - savings.totalWithdrawn - (old.kind == .deposit ? old.amount : -old.amount)
    }

    var current: Double { savings.currentSavings }

    var earliestDate: Date { Calendar.current.startOfDay(for: savings.startDate) }

    /// Savings left once this entry is applied.
    var savingsAfter: Double? {
        guard amount > 0 else { return nil }
        return kind == .deposit ? baseSavings + amount : baseSavings - amount
    }

    /// Chosen account's balance once this entry is applied.
    var balanceAfter: Double? {
        guard amount > 0, let account else { return nil }
        var balance = account.balance
        if let old = editingEntry?.account, old.id == account.id, let entry = editingEntry {
            balance -= entry.accountDelta   // undo the old effect first
        }
        return balance + (kind == .deposit ? -amount : amount)
    }

    var visibleError: String? {
        guard amount > 0 else { return nil }
        if let after = savingsAfter, after < -0.005 {
            return kind == .withdrawal
                ? "That's more than you have saved: \(CurrencyFormatter.taka(max(baseSavings, 0), showFraction: true))"
                : "This would leave more withdrawn than saved."
        }
        if kind == .deposit, let after = balanceAfter, after < -0.005, let account {
            return "\(account.name) doesn't have enough balance."
        }
        return nil
    }

    var canSubmit: Bool {
        amount > 0 && (!usesAccount || account != nil) && visibleError == nil
    }

    func withdrawAll() { amountText = DecimalInput.text(max(baseSavings, 0)) }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit else { return false }

        let entry = SavingsEntry(id: editingEntry?.id ?? UUID(),
                                 kind: kind, amount: amount, date: date,
                                 note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                                 account: account.map(AccountSummary.init))
        switch mode {
        case .create:
            switch kind {
            case .deposit:    dependencies.service.deposit(entry, to: savings.id)
            case .withdrawal: dependencies.service.withdraw(entry, from: savings.id)
            }
            return true
        case .edit:
            return dependencies.service.updateEntry(entry, in: savings.id)
        }
    }
}
