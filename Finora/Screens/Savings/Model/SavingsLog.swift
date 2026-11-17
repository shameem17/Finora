//
//  SavingsLog.swift
//  Finora
//
//  Screens/Savings/Model
//

import Foundation

enum SavingsLogFilter: String, PickerOption {
    case all = "All"
    case added = "Added"
    case withdrawn = "Withdrawn"

    var title: String { rawValue }

    func includes(_ kind: SavingsEntryKind) -> Bool {
        switch self {
        case .all:       return true
        case .added:     return kind == .deposit
        case .withdrawn: return kind == .withdrawal
        }
    }
}

/// One entry in the log, with the savings account it belongs to.
struct SavingsLogEntry: Identifiable, Hashable {
    let entry: SavingsEntry
    let savingsID: SavingsAccount.ID
    let savingsName: String

    var id: SavingsEntry.ID { entry.id }
}

/// Entries of one calendar month, newest first.
struct SavingsLogSection: Identifiable, Equatable {
    let id: Date
    let entries: [SavingsLogEntry]

    var added: Double { entries.lazy.filter { $0.entry.kind == .deposit }.reduce(0) { $0 + $1.entry.amount } }
    var withdrawn: Double { entries.lazy.filter { $0.entry.kind == .withdrawal }.reduce(0) { $0 + $1.entry.amount } }
    var net: Double { added - withdrawn }

    static func make(from entries: [SavingsLogEntry], calendar: Calendar = .current) -> [SavingsLogSection] {
        let grouped = Dictionary(grouping: entries) { log in
            calendar.date(from: calendar.dateComponents([.year, .month], from: log.entry.date)) ?? log.entry.date
        }
        return grouped
            .map { SavingsLogSection(id: $0.key, entries: $0.value.sorted { $0.entry.date > $1.entry.date }) }
            .sorted { $0.id > $1.id }
    }
}
