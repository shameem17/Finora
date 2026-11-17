//
//  LoanFormViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Observation

enum LoanFormError: Equatable {
    case missingPerson
    case missingAccount
    case invalidAmount
    case insufficientBalance(available: Double)
    case dueBeforeLoanDate
    case belowRepaid(repaid: Double)

    /// Only errors the user should *see* while typing carry a message;
    /// the rest simply keep the Save button disabled.
    var message: String? {
        switch self {
        case .insufficientBalance(let available):
            return "Not enough balance. Available: \(CurrencyFormatter.taka(available, showFraction: true))"
        case .dueBeforeLoanDate:
            return "The due date can't be before the loan date."
        case .belowRepaid(let repaid):
            return "Total can't be less than the \(CurrencyFormatter.taka(repaid, showFraction: true)) already repaid."
        case .missingPerson, .missingAccount, .invalidAmount:
            return nil
        }
    }
}

@Observable
final class LoanFormViewModel: Identifiable {

    enum Mode {
        case create(kind: LoanKind)
        case edit(Loan)
    }

    let id = UUID()
    let mode: Mode

    /// Accounts the money can move through (create only).
    let accounts: [Account]
    private(set) var people: [Person]

    var kind: LoanKind
    var personID: Person.ID?
    var accountID: Account.ID?
    var amountText = ""
    var interestText = ""
    var date: Date = .now
    var hasDueDate = false
    var dueDate: Date
    var installmentCount = 1
    var note = ""

    private let editingLoan: Loan?
    private let dependencies: LoanDependencies
    private let calendar: Calendar

    // MARK: Init

    init(mode: Mode, dependencies: LoanDependencies, calendar: Calendar = .current) {
        self.mode = mode
        self.dependencies = dependencies
        self.calendar = calendar
        self.people = dependencies.people.fetchPeople()
        self.dueDate = calendar.date(byAdding: .month, value: 1, to: .now) ?? .now

        switch mode {
        case .create(let kind):
            let available = dependencies.accounts.fetchAccounts()
            self.kind = kind
            self.accounts = available
            self.accountID = available.first?.id
            self.editingLoan = nil

        case .edit(let loan):
            self.kind = loan.kind
            self.accounts = []
            self.accountID = loan.account.id
            self.editingLoan = loan
            self.personID = loan.personID
            self.amountText = DecimalInput.text(loan.principal)
            self.interestText = loan.interest > 0 ? DecimalInput.text(loan.interest) : ""
            self.date = loan.date
            if let due = loan.dueDate {
                self.hasDueDate = true
                self.dueDate = due
            }
            self.installmentCount = loan.installmentCount
            self.note = loan.note ?? ""
        }
    }

    // MARK: Derived

    var isEditing: Bool { editingLoan != nil }

    var title: String {
        switch (isEditing, kind) {
        case (false, .lent):     return "New Loan"
        case (false, .borrowed): return "New Borrow"
        case (true, .lent):      return "Edit Loan"
        case (true, .borrowed):  return "Edit Borrow"
        }
    }

    var saveTitle: String {
        isEditing ? "Save Changes" : (kind == .lent ? "Save Loan" : "Save Borrow")
    }

    var person: Person? { people.first { $0.id == personID } }
    var account: Account? { accounts.first { $0.id == accountID } }
    /// The (read-only) account of a loan being edited.
    var lockedAccount: AccountSummary? { editingLoan?.account }

    var amount: Double {
        editingLoan?.principal ?? DecimalInput.value(of: amountText)
    }
    var interest: Double { DecimalInput.value(of: interestText) }
    var totalPayable: Double { amount + interest }

    var installmentAmount: Double? {
        guard hasDueDate, installmentCount > 1 else { return nil }
        return totalPayable / Double(installmentCount)
    }

    /// Account balance once the principal has moved (create only).
    var balanceAfter: Double? {
        guard !isEditing, let account, amount > 0 else { return nil }
        return account.balance + kind.principalDelta(amount)
    }

    var visibleError: String? { validate()?.message }
    var canSubmit: Bool { validate() == nil }

    // MARK: Intents

    /// Keeps the due date from falling behind the loan date while the user scrubs dates.
    func loanDateChanged() {
        if calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: date) {
            dueDate = date
        }
    }

    func makePersonFormViewModel() -> PersonFormViewModel {
        PersonFormViewModel(mode: .create, repository: dependencies.people) { [weak self] person in
            guard let self else { return }
            self.people = self.dependencies.people.fetchPeople()
            self.personID = person.id
        }
    }

    @discardableResult
    func submit() -> Bool {
        guard validate() == nil, let personID else { return false }

        let due = hasDueDate ? calendar.startOfDay(for: dueDate) : nil
        let installments = due == nil ? 1 : min(max(installmentCount, 1), Loan.maxInstallments)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote

        if let editingLoan {
            // Re-read so repayments recorded since the form opened are never lost.
            var loan = dependencies.loans.loan(id: editingLoan.id) ?? editingLoan
            loan.personID = personID
            loan.interest = interest
            loan.date = date
            loan.dueDate = due
            loan.installmentCount = installments
            loan.note = finalNote
            dependencies.service.update(loan)
        } else {
            guard let account else { return false }
            let loan = Loan(kind: kind,
                            personID: personID,
                            account: AccountSummary(account),
                            principal: amount,
                            interest: interest,
                            date: date,
                            dueDate: due,
                            installmentCount: installments,
                            note: finalNote)
            dependencies.service.create(loan)
        }
        return true
    }

    // MARK: Validation

    func validate() -> LoanFormError? {
        guard person != nil else { return .missingPerson }

        if let editingLoan {
            let repaid = dependencies.loans.loan(id: editingLoan.id)?.totalRepaid ?? editingLoan.totalRepaid
            if repaid > totalPayable + Loan.tolerance { return .belowRepaid(repaid: repaid) }
        } else {
            guard let account else { return .missingAccount }
            guard amount > 0 else { return .invalidAmount }
            if kind == .lent, amount > account.balance + Loan.tolerance {
                return .insufficientBalance(available: account.balance)
            }
        }

        if hasDueDate, calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: date) {
            return .dueBeforeLoanDate
        }
        return nil
    }

    // MARK: Helpers
}
