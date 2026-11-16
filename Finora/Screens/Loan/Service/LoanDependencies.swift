//
//  LoanDependencies.swift
//  Finora
//
//  Screens/Loan/Service
//

import Foundation

/// Everything the Loan screens need, in one injectable bundle. Tests and
/// previews build their own; the app uses `live`.
struct LoanDependencies {
    let loans: LoanRepositoryProtocol
    let people: PersonRepositoryProtocol
    let accounts: AccountRepositoryProtocol
    let service: LoanServiceProtocol

    static func live(isRemindersEnabled: @escaping () -> Bool = { true }) -> LoanDependencies {
        let loans = InMemoryLoanRepository.shared
        let people = InMemoryPersonRepository.shared
        let accounts = InMemoryAccountRepository.shared
        let service = LoanService(loans: loans,
                                  people: people,
                                  accounts: accounts,
                                  reminders: LoanReminderScheduler(isEnabled: isRemindersEnabled))
        return LoanDependencies(loans: loans, people: people, accounts: accounts, service: service)
    }
}

#if DEBUG
extension LoanDependencies {
    /// Isolated, sample-filled dependencies for SwiftUI previews.
    static func preview() -> LoanDependencies {
        let accounts = InMemoryAccountRepository()
        let people = InMemoryPersonRepository(people: LoanSampleData.people)
        let loans = InMemoryLoanRepository(
            loans: LoanSampleData.loans(people: people.fetchPeople(),
                                        accounts: accounts.fetchAccounts())
        )
        let service = LoanService(loans: loans,
                                  people: people,
                                  accounts: accounts,
                                  reminders: NoopLoanReminderScheduler())
        return LoanDependencies(loans: loans, people: people, accounts: accounts, service: service)
    }
}
#endif
