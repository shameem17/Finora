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


// MARK: - Date-range helpers

extension ReportPeriod {

    /// Whether `date` falls inside the current week / month / year (always true for `.all`).
    func contains(_ date: Date, calendar: Calendar = .current, now: Date = .now) -> Bool {
        switch self {
        case .week:  return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .month: return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .year:  return calendar.isDate(date, equalTo: now, toGranularity: .year)
        case .all:   return true
        }
    }

    /// Exclusive end of the current period (start of the next one). `.distantFuture` for `.all`.
    func endDate(calendar: Calendar = .current, now: Date = .now) -> Date {
        let component: Calendar.Component
        switch self {
        case .week:  component = .weekOfYear
        case .month: component = .month
        case .year:  component = .year
        case .all:   return .distantFuture
        }
        return calendar.dateInterval(of: component, for: now)?.end ?? .distantFuture
    }
}
