//
//  CashFlowFormViewModel.swift
//  Finora
//
//  Screens/CashFlow/ViewModel
//

import Foundation
import Observation

@Observable
final class CashFlowFormViewModel: Identifiable {

    enum Mode {
        case create(kind: CategoryKind)
        case edit(CashFlowEntry)
    }

    let id = UUID()
    let mode: Mode
    let kind: CategoryKind
    let categories: [TransactionCategory]
    let accounts: [Account]

    var amountText = ""
    var categoryID: TransactionCategory.ID?
    var accountID: Account.ID?
    var date: Date = .now
    var note = ""

    @ObservationIgnored private let dependencies: CashFlowDependencies

    init(mode: Mode, dependencies: CashFlowDependencies) {
        let kind: CategoryKind
        let editing: CashFlowEntry?
        switch mode {
        case .create(let createKind):
            kind = createKind
            editing = nil
        case .edit(let entry):
            kind = entry.kind
            editing = entry
        }

        let accounts = dependencies.accounts.fetchAccounts()
        let categories = dependencies.categories.fetchCategories(kind: kind)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        self.mode = mode
        self.kind = kind
        self.dependencies = dependencies
        self.accounts = accounts
        self.categories = categories

        if let editing {
            amountText = DecimalInput.text(editing.amount)
            categoryID = editing.categoryID
            accountID = editing.accountID
            date = editing.date
            note = editing.note
        } else {
            categoryID = categories.first?.id
            accountID = accounts.first?.id
        }
    }

    // MARK: Derived

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { (isEditing ? "Edit " : "New ") + kind.title }
    var saveTitle: String { isEditing ? "Save Changes" : kind.addTitle }

    private var editingEntry: CashFlowEntry? {
        if case .edit(let entry) = mode { return entry }
        return nil
    }

    var amount: Double { DecimalInput.value(of: amountText) }
    var account: Account? { accounts.first { $0.id == accountID } }
    var hasCategories: Bool { !categories.isEmpty }

    /// Selected account's balance once this entry is applied.
    var balanceAfter: Double? {
        guard amount > 0, let account else { return nil }
        var balance = account.balance
        if let old = editingEntry, old.accountID == account.id { balance -= old.accountDelta }
        return balance + (kind == .income ? amount : -amount)
    }

    var visibleError: String? {
        guard amount > 0, kind == .expense, let after = balanceAfter, after < -0.005, let account else { return nil }
        return "\(account.name) doesn't have enough balance."
    }

    var canSubmit: Bool {
        amount > 0 && categoryID != nil && account != nil && visibleError == nil
    }

    // MARK: Intents

    @discardableResult
    func submit() -> Bool {
        guard canSubmit, let categoryID, let accountID else { return false }

        let entry = CashFlowEntry(id: editingEntry?.id ?? UUID(),
                                  kind: kind, categoryID: categoryID, accountID: accountID,
                                  amount: amount, date: date,
                                  note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        if isEditing {
            dependencies.service.update(entry)
        } else {
            dependencies.service.record(entry)
        }
        return true
    }

    func delete() {
        guard let editingEntry else { return }
        dependencies.service.delete(id: editingEntry.id)
    }
}
