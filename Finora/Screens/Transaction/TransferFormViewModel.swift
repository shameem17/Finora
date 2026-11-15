//
//  TransferFormViewModel.swift
//  Finora
//
//  Screens/Transaction/ViewModel
//

import Foundation
import Observation

enum TransferValidationError: Equatable {
    case missingSource
    case missingDestination
    case sameAccount
    case invalidAmount
    case insufficientBalance(available: Double)

    /// Only errors the user should *see* while typing carry a message;
    /// the rest simply keep the Save button disabled.
    var message: String? {
        switch self {
        case .sameAccount:
            return "Choose two different accounts."
        case .insufficientBalance(let available):
            return "Not enough balance. Available: \(CurrencyFormatter.taka(available, showFraction: true))"
        case .missingSource, .missingDestination, .invalidAmount:
            return nil
        }
    }
}

@Observable
final class TransferFormViewModel: Identifiable {

    let id = UUID()
    let accounts: [Account]

    var fromID: Account.ID?
    var toID: Account.ID?
    var amountText = ""
    var chargeText = ""
    var date: Date = .now
    var reason = ""

    private let onSave: (Transfer) -> Void

    init(accounts: [Account], onSave: @escaping (Transfer) -> Void) {
        self.accounts = accounts
        self.fromID = accounts.first?.id
        self.onSave = onSave
    }

    // MARK: Derived

    var fromAccount: Account? { accounts.first { $0.id == fromID } }
    var toAccount: Account? { accounts.first { $0.id == toID } }

    var amount: Double { DecimalInput.value(of: amountText) }
    var charge: Double { DecimalInput.value(of: chargeText) }
    var totalDebit: Double { amount + charge }

    var balanceAfter: Double? {
        guard let from = fromAccount, amount > 0 else { return nil }
        return from.balance - totalDebit
    }

    var visibleError: String? { validate()?.message }
    var canSubmit: Bool { validate() == nil }

    // MARK: Intents

    func swapAccounts() {
        let previousFrom = fromID
        fromID = toID
        toID = previousFrom
    }

    @discardableResult
    func submit() -> Bool {
        guard validate() == nil,
              let from = fromAccount,
              let to = toAccount else { return false }

        let transfer = Transfer(
            id: UUID(),
            from: AccountSummary(from),
            to: AccountSummary(to),
            amount: amount,
            charge: charge,
            date: date,
            reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        onSave(transfer)
        return true
    }

    // MARK: Validation

    func validate() -> TransferValidationError? {
        guard let from = fromAccount else { return .missingSource }
        guard let to = toAccount else { return .missingDestination }
        guard from.id != to.id else { return .sameAccount }
        guard amount > 0 else { return .invalidAmount }
        guard totalDebit <= from.balance + 0.005 else {
            return .insufficientBalance(available: from.balance)
        }
        return nil
    }
}
