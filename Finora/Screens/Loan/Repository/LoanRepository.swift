//
//  LoanRepository.swift
//  Finora
//
//  Screens/Loan/Repository
//

import Foundation
import Combine

protocol LoanRepositoryProtocol: ChangeNotifying {
    func fetchLoans() -> [Loan]
    func loan(id: Loan.ID) -> Loan?
    func add(_ loan: Loan)
    func update(_ loan: Loan)
    func delete(id: Loan.ID)
}

/// In-memory implementation. Swap for SwiftData / Core Data later without
/// touching any view model.
final class InMemoryLoanRepository: LoanRepositoryProtocol {

    static let shared: InMemoryLoanRepository = {
        #if DEBUG
        let loans = LoanSampleData.loans(
            people: InMemoryPersonRepository.shared.fetchPeople(),
            accounts: InMemoryAccountRepository.shared.fetchAccounts()
        )
        return InMemoryLoanRepository(loans: loans)
        #else
        return InMemoryLoanRepository()
        #endif
    }()

    private let store: InMemoryStore<Loan>

    init(loans: [Loan] = []) {
        store = InMemoryStore(loans)
    }

    var changes: AnyPublisher<Void, Never> { store.changes }

    func fetchLoans() -> [Loan] { store.items }
    func loan(id: Loan.ID) -> Loan? { store.item(id: id) }
    func add(_ loan: Loan) { store.add(loan) }
    func update(_ loan: Loan) { store.update(loan) }
    func delete(id: Loan.ID) { store.remove(id: id) }
}
