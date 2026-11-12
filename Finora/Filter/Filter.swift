//
//  Filter.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import Foundation

// MARK: - Period filter (shared with Expense)

enum ReportPeriod: String, PickerOption {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"

    var id: Self { self }

    /// Human-readable range shown next to the card title.
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
}

