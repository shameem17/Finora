//
//  SavingsModels.swift
//  Finora
//
//  Screens/Savings/Model
//

import Foundation

enum SavingsEntryKind: String, Hashable {
    case deposit
    case withdrawal

    var title: String { self == .deposit ? "Add Savings" : "Withdraw" }
    var historyTitle: String { self == .deposit ? "Deposit" : "Withdrawal" }
    var icon: String { self == .deposit ? "arrow.down.to.line" : "arrow.up.right" }
    var tint: CustomColor { self == .deposit ? .incoming : .outgoing }
    var accountTitle: String { self == .deposit ? "Take money from" : "Send money to" }
    var sign: String { self == .deposit ? "+" : "−" }
}

/// One movement of money into or out of a savings account.
struct SavingsEntry: Identifiable, Hashable {
    let id: UUID
    let kind: SavingsEntryKind
    let amount: Double
    let date: Date
    let note: String
    /// The regular account the money came from (deposit) or went to (withdrawal).
    /// `nil` when the money moved outside your Finora accounts (no balance is changed).
    let account: AccountSummary?

    init(id: UUID = UUID(), kind: SavingsEntryKind, amount: Double,
         date: Date = .now, note: String = "", account: AccountSummary? = nil) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.date = date
        self.note = note
        self.account = account
    }

    /// Effect this entry has on the linked account's balance.
    var accountDelta: Double { kind == .deposit ? -amount : amount }
}

/// A savings pot tagged to a regular account, e.g. "City Bank Savings".
/// It is separate from the regular accounts list: its money only moves through
/// deposits and withdrawals, which debit / credit a regular account.
struct SavingsAccount: Identifiable, Hashable {
    static let suffix = "Savings"

    let id: UUID
    var name: String
    /// Optional account / deposit-scheme number.
    var number: String
    /// The regular account this savings account is tagged to.
    var accountID: Account.ID
    var logoData: Data?
    var tint: String
    var startDate: Date
    var target: Double?
    var targetDate: Date?
    var note: String
    /// Money already saved before tracking started. Does not touch any account.
    var openingBalance: Double
    var entries: [SavingsEntry]

    init(id: UUID = UUID(),
         name: String,
         number: String = "",
         accountID: Account.ID,
         logoData: Data? = nil,
         tint: String,
         startDate: Date = .now,
         target: Double? = nil,
         targetDate: Date? = nil,
         note: String = "",
         openingBalance: Double = 0,
         entries: [SavingsEntry] = []) {
        self.id = id
        self.name = name
        self.number = number
        self.accountID = accountID
        self.logoData = logoData
        self.tint = tint
        self.startDate = startDate
        self.target = target
        self.targetDate = targetDate
        self.note = note
        self.openingBalance = openingBalance
        self.entries = entries
    }

    // MARK: Calculated

    var totalDeposited: Double {
        openingBalance + entries.lazy.filter { $0.kind == .deposit }.reduce(0) { $0 + $1.amount }
    }

    var totalWithdrawn: Double {
        entries.lazy.filter { $0.kind == .withdrawal }.reduce(0) { $0 + $1.amount }
    }

    var currentSavings: Double { max(totalDeposited - totalWithdrawn, 0) }

    var progress: Double? {
        guard let target, target > 0 else { return nil }
        return min(currentSavings / target, 1)
    }

    var remainingToTarget: Double? {
        target.map { max($0 - currentSavings, 0) }
    }

    var isGoalReached: Bool {
        guard let target, target > 0 else { return false }
        return currentSavings >= target
    }

    var sortedEntries: [SavingsEntry] { entries.sorted { $0.date > $1.date } }

    /// Appends " Savings" unless the name already ends with it.
    static func suffixed(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed.lowercased().hasSuffix(suffix.lowercased()) ? trimmed : "\(trimmed) \(suffix)"
    }
}

/// A savings account paired with its tagged regular account, ready to display.
struct SavingsItem: Identifiable, Hashable {
    let savings: SavingsAccount
    let account: AccountSummary?

    var id: SavingsAccount.ID { savings.id }
}
