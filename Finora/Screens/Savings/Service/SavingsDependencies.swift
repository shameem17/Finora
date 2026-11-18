//
//  SavingsDependencies.swift
//  Finora
//
//  Screens/Savings/Service
//

import Foundation

/// Everything the Savings screens need, in one injectable bundle.
struct SavingsDependencies {
    let savings: SavingsRepositoryProtocol
    let accounts: AccountRepositoryProtocol
    let service: SavingsServiceProtocol

    static func live() -> SavingsDependencies {
        let savings = SwiftDataSavingsRepository.shared
        let accounts = SwiftDataAccountRepository.shared
        return SavingsDependencies(savings: savings, accounts: accounts,
                                   service: SavingsService(savings: savings, accounts: accounts,
                                                           unitOfWork: PersistenceController.shared))
    }

    #if DEBUG
    static func preview() -> SavingsDependencies {
        let accounts = InMemoryAccountRepository()
        let savings = InMemorySavingsRepository(savings: SavingsSampleData.savings(accounts: accounts.fetchAccounts()))
        return SavingsDependencies(savings: savings, accounts: accounts,
                                   service: SavingsService(savings: savings, accounts: accounts))
    }
    #endif
}
