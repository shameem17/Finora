//
//  LoanService.swift
//  Finora
//
//  Screens/Loan/Service
//

import Foundation

/// Every write goes through here so account balances, loan records and
/// reminders can never drift apart.
protocol LoanServiceProtocol: AnyObject {
    /// Saves the loan and moves the principal through its account.
    func create(_ loan: Loan)
    /// Saves edited terms (person, dates, interest, note). Money fields are not touched.
    func update(_ loan: Loan)
    /// Removes the loan and reverses every balance movement it caused.
    func delete(loanID: Loan.ID)
    func addRepayment(_ repayment: Repayment, to loanID: Loan.ID)
    func deleteRepayment(id: Repayment.ID, from loanID: Loan.ID)
}

final class LoanService: LoanServiceProtocol {

    private let loans: LoanRepositoryProtocol
    private let people: PersonRepositoryProtocol
    private let accounts: AccountRepositoryProtocol
    private let reminders: LoanReminderScheduling
    private let unitOfWork: UnitOfWork

    init(loans: LoanRepositoryProtocol,
         people: PersonRepositoryProtocol,
         accounts: AccountRepositoryProtocol,
         reminders: LoanReminderScheduling,
         unitOfWork: UnitOfWork = ImmediateUnitOfWork()) {
        self.loans = loans
        self.people = people
        self.accounts = accounts
        self.reminders = reminders
        self.unitOfWork = unitOfWork
    }

    // MARK: LoanServiceProtocol
    //
    // Money and records change inside one atomic commit; reminders are synced
    // afterwards from what was actually stored.

    func create(_ loan: Loan) {
        unitOfWork.perform {
            accounts.adjustBalance(of: loan.account.id, by: loan.kind.principalDelta(loan.principal))
            loans.add(loan)
        }
        syncReminder(for: loan.id)
    }

    func update(_ loan: Loan) {
        unitOfWork.perform { loans.update(loan) }
        syncReminder(for: loan.id)
    }

    func delete(loanID: Loan.ID) {
        unitOfWork.perform {
            guard let loan = loans.loan(id: loanID) else { return }

            accounts.adjustBalance(of: loan.account.id, by: -loan.kind.principalDelta(loan.principal))
            for repayment in loan.repayments {
                accounts.adjustBalance(of: repayment.account.id, by: -loan.kind.repaymentDelta(repayment.amount))
            }
            loans.delete(id: loanID)
        }
        reminders.cancel(loanID: loanID)
    }

    func addRepayment(_ repayment: Repayment, to loanID: Loan.ID) {
        unitOfWork.perform {
            guard var loan = loans.loan(id: loanID) else { return }

            accounts.adjustBalance(of: repayment.account.id, by: loan.kind.repaymentDelta(repayment.amount))
            loan.repayments.append(repayment)
            loans.update(loan)
        }
        syncReminder(for: loanID)
    }

    func deleteRepayment(id: Repayment.ID, from loanID: Loan.ID) {
        unitOfWork.perform {
            guard var loan = loans.loan(id: loanID),
                  let repayment = loan.repayments.first(where: { $0.id == id }) else { return }

            accounts.adjustBalance(of: repayment.account.id, by: -loan.kind.repaymentDelta(repayment.amount))
            loan.repayments.removeAll { $0.id == id }
            loans.update(loan)
        }
        syncReminder(for: loanID)
    }

    // MARK: Private

    private func syncReminder(for id: Loan.ID) {
        guard let loan = loans.loan(id: id) else {
            reminders.cancel(loanID: id)
            return
        }
        reminders.sync(loan, person: people.person(id: loan.personID))
    }
}
