//
//  LoanReminderScheduler.swift
//  Finora
//
//  Screens/Loan/Service
//

import Foundation
import UserNotifications

/// Keeps one local reminder per loan, pointing at its next unpaid installment.
protocol LoanReminderScheduling: AnyObject {
    /// Replaces any existing reminder for the loan (or removes it if nothing is due).
    func sync(_ loan: Loan, person: Person?)
    func cancel(loanID: Loan.ID)
}

final class NoopLoanReminderScheduler: LoanReminderScheduling {
    func sync(_ loan: Loan, person: Person?) {}
    func cancel(loanID: Loan.ID) {}
}

/// Local notifications only: fully offline and free on battery (the system
/// delivers them, the app never wakes up in the background).
final class LoanReminderScheduler: LoanReminderScheduling {

    private let center: UNUserNotificationCenter
    private let calendar: Calendar
    private let isEnabled: () -> Bool
    private let reminderHour = 9

    init(center: UNUserNotificationCenter = .current(),
         calendar: Calendar = .current,
         isEnabled: @escaping () -> Bool = { true }) {
        self.center = center
        self.calendar = calendar
        self.isEnabled = isEnabled
    }

    func sync(_ loan: Loan, person: Person?) {
        cancel(loanID: loan.id)

        guard isEnabled(),
              !loan.isSettled,
              let next = loan.nextInstallment(calendar: calendar),
              let fireDate = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: next.dueDate),
              fireDate > .now
        else { return }

        let name = person?.name ?? "someone"
        let amount = CurrencyFormatter.taka(next.remaining, showFraction: true)

        let content = UNMutableNotificationContent()
        content.sound = .default
        switch loan.kind {
        case .borrowed:
            content.title = "Payment due today"
            content.body = "Pay \(amount) to \(name)."
        case .lent:
            content.title = "Repayment due today"
            content.body = "\(name) is due to repay \(amount)."
        }

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier(for: loan.id),
                                            content: content,
                                            trigger: trigger)

        Task { await schedule(request) }
    }

    func cancel(loanID: Loan.ID) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: loanID)])
    }

    // MARK: Private

    private func identifier(for id: Loan.ID) -> String {
        "finora.loan.\(id.uuidString)"
    }

    /// Asks for permission lazily, the first time a reminder is actually useful.
    private func schedule(_ request: UNNotificationRequest) async {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else { return }
        case .authorized, .provisional, .ephemeral:
            break
        default:
            return
        }
        try? await center.add(request)
    }
}
