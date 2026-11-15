//
//  Transfer.swift
//  Finora
//
//  Screens/Transaction/Model
//

import Foundation

// MARK: - Account snapshot

/// Lightweight, immutable reference to an account, stored with each transfer
/// so history rows never depend on the account's *current* balance.
struct AccountSummary: Hashable {
    let id: Account.ID
    let name: String
    let tint: String
    let type: AccountType

    init(_ account: Account) {
        self.id = account.id
        self.name = account.name
        self.tint = account.tint
        self.type = account.type
    }
}

// MARK: - Transfer

struct Transfer: Identifiable, Hashable {
    let id: UUID
    let from: AccountSummary
    let to: AccountSummary
    let amount: Double
    let charge: Double
    let date: Date
    let reason: String

    /// What actually leaves the source account.
    var totalDebited: Double { amount + charge }
}

// MARK: - Presentation models

struct TransferSummary: Equatable {
    var totalAmount: Double = 0
    var totalCharges: Double = 0
    var count: Int = 0

    static let empty = TransferSummary()
}

struct TransferSection: Identifiable {
    let id: Date                 // start of day
    let title: String
    let transfers: [Transfer]
}

// MARK: - Period filter

enum TransferPeriod: String, PickerOption {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"

    /// Human-readable range shown on the summary card.
    var subtitle: String {
        let cal = Calendar.current
        let now = Date()
        switch self {
        case .week:
            guard let interval = cal.dateInterval(of: .weekOfYear, for: now) else { return "This week" }
            let end = cal.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
            let style = Date.FormatStyle().day().month(.abbreviated)
            return "\(interval.start.formatted(style)) – \(end.formatted(style))"
        case .month:
            return now.formatted(.dateTime.month(.wide).year())
        case .year:
            return now.formatted(.dateTime.year())
        case .all:
            return "All time"
        }
    }

    func contains(_ date: Date, calendar: Calendar = .current, now: Date = .now) -> Bool {
        switch self {
        case .week:  return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .month: return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .year:  return calendar.isDate(date, equalTo: now, toGranularity: .year)
        case .all:   return true
        }
    }
}
