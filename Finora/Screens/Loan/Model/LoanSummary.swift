//
//  LoanSummary.swift
//  Finora
//
//  Screens/Loan/Model
//

import Foundation

// MARK: - Summary

struct LoanSummary: Equatable {

    // Outstanding right now (not period dependent).
    var toReceive = 0.0
    var toPay = 0.0
    var activeLentCount = 0
    var activeBorrowedCount = 0

    // Flow inside the selected period.
    var lentInPeriod = 0.0
    var borrowedInPeriod = 0.0
    var receivedInPeriod = 0.0
    var repaidInPeriod = 0.0

    // Scheduled up to the end of the selected period (includes anything overdue).
    var dueToReceive = 0.0
    var dueToPay = 0.0
    var overdueToReceive = 0.0
    var overdueToPay = 0.0

    var net: Double { toReceive - toPay }

    static let empty = LoanSummary()
}

extension LoanSummary {

    static func make(loans: [Loan],
                     period: ReportPeriod,
                     calendar: Calendar = .current,
                     now: Date = .now) -> LoanSummary {
        var summary = LoanSummary()
        let periodEnd = period.endDate(calendar: calendar, now: now)
        let today = calendar.startOfDay(for: now)

        for loan in loans {
            let isLent = loan.kind == .lent

            if period.contains(loan.date, calendar: calendar, now: now) {
                if isLent { summary.lentInPeriod += loan.principal }
                else { summary.borrowedInPeriod += loan.principal }
            }

            let repaidInPeriod = loan.repayments
                .filter { period.contains($0.date, calendar: calendar, now: now) }
                .reduce(0) { $0 + $1.amount }
            if isLent { summary.receivedInPeriod += repaidInPeriod }
            else { summary.repaidInPeriod += repaidInPeriod }

            guard !loan.isSettled else { continue }

            let due = loan.amountDue(before: periodEnd, calendar: calendar)
            let overdue = loan.amountDue(before: today, calendar: calendar)

            if isLent {
                summary.toReceive += loan.outstanding
                summary.activeLentCount += 1
                summary.dueToReceive += due
                summary.overdueToReceive += overdue
            } else {
                summary.toPay += loan.outstanding
                summary.activeBorrowedCount += 1
                summary.dueToPay += due
                summary.overdueToPay += overdue
            }
        }
        return summary
    }
}

// MARK: - Sections

struct LoanSection: Identifiable {

    enum Group: Hashable {
        case overdue, active, settled

        var title: String {
            switch self {
            case .overdue: return "Overdue"
            case .active:  return "Active"
            case .settled: return "Settled"
            }
        }
    }

    let group: Group
    let items: [LoanItem]

    var id: Group { group }
}
