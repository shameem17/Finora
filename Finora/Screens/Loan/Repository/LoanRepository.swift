//
//  LoanRepository.swift
//  Finora
//
//  Screens/Loan/Repository
//

import Foundation
import Combine

protocol LoanRepositoryProtocol: AnyObject {
    /// Emits after every mutation so screens can refresh without polling.
    var changes: AnyPublisher<Void, Never> { get }

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

    private var loans: [Loan]
    private let subject = PassthroughSubject<Void, Never>()

    init(loans: [Loan] = []) {
        self.loans = loans
    }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchLoans() -> [Loan] { loans }

    func loan(id: Loan.ID) -> Loan? {
        loans.first { $0.id == id }
    }

    func add(_ loan: Loan) {
        loans.append(loan)
        subject.send()
    }

    func update(_ loan: Loan) {
        guard let index = loans.firstIndex(where: { $0.id == loan.id }) else { return }
        loans[index] = loan
        subject.send()
    }

    func delete(id: Loan.ID) {
        loans.removeAll { $0.id == id }
        subject.send()
    }
}
