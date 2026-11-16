//
//  RepaymentFormViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Observation

enum RepaymentValidationError: Equatable {
    case missingAccount
    case invalidAmount
    case exceedsOutstanding(outstanding: Double)
    case insufficientBalance(available: Double)

    var message: String? {
        switch self {
        case .exceedsOutstanding(let outstanding):
            return "That's more than what's left: \(CurrencyFormatter.taka(outstanding, showFraction: true))"
        case .insufficientBalance(let available):
            return "Not enough balance. Available: \(CurrencyFormatter.taka(available, showFraction: true))"
        case .missingAccount, .invalidAmount:
            return nil
        }
    }
}

@Observable
final class RepaymentFormViewModel: Identifiable {

    let id = UUID()
    let item: LoanItem
    let accounts: [Account]

    var accountID: Account.ID?
    var amountText = ""
    var date: Date = .now
    var note = ""

    private let dependencies: LoanDependencies
    private let calendar: Calendar

    init(item: LoanItem, dependencies: LoanDependencies, calendar: Calendar = .current) {
        let available = dependencies.accounts.fetchAccounts()
        self.item = item
        self.dependencies = dependencies
        self.calendar = calendar
        self.accounts = available
        // Default to the account the loan went through, when it still exists.
        self.accountID = (available.first { $0.id == item.loan.account.id } ?? available.first)?.id
    }

    // MARK: Derived

    var loan: Loan { item.loan }
    var kind: LoanKind { loan.kind }
    var outstanding: Double { loan.outstanding }
    var account: Account? { accounts.first { $0.id == accountID } }
    var amount: Double { DecimalInput.value(of: amountText) }

    var nextInstallment: Installment? {
        // Only worth offering when it differs from simply paying everything.
        guard let next = loan.nextInstallment(calendar: calendar),
              loan.installmentCount > 1 else { return nil }
        return next
    }

    /// Earliest date a repayment can carry: the day the loan was made.
    var earliestDate: Date { calendar.startOfDay(for: loan.date) }

    var remainingAfter: Double? {
        amount > 0 ? max(outstanding - amount, 0) : nil
    }

    var balanceAfter: Double? {
        guard let account, amount > 0 else { return nil }
        return account.balance + kind.repaymentDelta(amount)
    }

    var visibleError: String? { validate()?.message }
    var canSubmit: Bool { validate() == nil }

    // MARK: Intents

    func payInFull() {
        amountText = Self.text(outstanding)
    }

    func payNextInstallment() {
        guard let nextInstallment else { return }
        amountText = Self.text(nextInstallment.remaining)
    }

    @discardableResult
    func submit() -> Bool {
        guard validate() == nil, let account else { return false }

        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let repayment = Repayment(amount: amount,
                                  date: date,
                                  account: AccountSummary(account),
                                  note: trimmed.isEmpty ? nil : trimmed)
        dependencies.service.addRepayment(repayment, to: loan.id)
        return true
    }

    // MARK: Validation

    func validate() -> RepaymentValidationError? {
        guard let account else { return .missingAccount }
        guard amount > 0 else { return .invalidAmount }
        guard amount <= outstanding + Loan.tolerance else {
            return .exceedsOutstanding(outstanding: outstanding)
        }
        // Paying a borrowed loan takes money out of the account; receiving never does.
        if kind == .borrowed, amount > account.balance + Loan.tolerance {
            return .insufficientBalance(available: account.balance)
        }
        return nil
    }

    // MARK: Helpers

    private static func text(_ value: Double) -> String {
        value.formatted(
            .number
                .locale(Locale(identifier: "en_US_POSIX"))
                .grouping(.never)
                .precision(.fractionLength(0...2))
        )
    }
}
