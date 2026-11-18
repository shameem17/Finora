//
//  CashFlowModels.swift
//  Finora
//
//  Screens/CashFlow/Model
//
//  Income and expense records. Each one belongs to a category and an account,
//  and moves that account's balance.
//

import Foundation

struct CashFlowEntry: Identifiable, Hashable {
    let id: UUID
    let kind: CategoryKind
    var categoryID: TransactionCategory.ID
    var accountID: Account.ID
    var amount: Double
    var date: Date
    var note: String

    init(id: UUID = UUID(),
         kind: CategoryKind,
         categoryID: TransactionCategory.ID,
         accountID: Account.ID,
         amount: Double,
         date: Date = .now,
         note: String = "") {
        self.id = id
        self.kind = kind
        self.categoryID = categoryID
        self.accountID = accountID
        self.amount = amount
        self.date = date
        self.note = note
    }

    /// Effect on the account's balance: income adds, expense subtracts.
    var accountDelta: Double { kind == .income ? amount : -amount }
}

/// An entry together with the category and account it points to, ready to display.
struct CashFlowItem: Identifiable, Hashable {
    let entry: CashFlowEntry
    /// `nil` when the category was deleted after the entry was recorded.
    let category: TransactionCategory?
    let account: AccountSummary?

    var id: CashFlowEntry.ID { entry.id }
}

extension CategoryKind {
    var screenTitle: String { self == .income ? "Income" : "Expenses" }
    var addTitle: String { self == .income ? "Add Income" : "Add Expense" }
    var totalTitle: String { self == .income ? "Total Income" : "Total Expense" }
    var centerCaption: String { self == .income ? "Earned" : "Spent" }
    var accountTitle: String { self == .income ? "Deposit to" : "Pay from" }
    var tint: CustomColor { self == .income ? .accent : .accent }
}
