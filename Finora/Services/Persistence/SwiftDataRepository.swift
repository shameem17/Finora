//
//  SwiftDataRepositories.swift
//  Finora
//
//  Services/Persistence
//
//  Disk-backed implementations of every repository protocol. Each is a singleton
//  (`.shared`), so one instance's `changes` publisher keeps every screen in sync.
//  Reads return fresh domain structs; writes go through `PersistenceController.write`
//  and therefore join any surrounding `UnitOfWork.perform { }` transaction.
//

import Foundation
import SwiftData
import Combine

// MARK: - Accounts

final class SwiftDataAccountRepository: AccountRepositoryProtocol {

    static let shared = SwiftDataAccountRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchAccounts() -> [Account] {
        persistence.fetchAll(AccountEntity.self, sortBy: [SortDescriptor(\AccountEntity.createdAt)]).map(\.domain)
    }

    func account(id: Account.ID) -> Account? { entity(id)?.domain }

    func add(_ account: Account) {
        persistence.write(notifying: subject) { $0.insert(AccountEntity(account)) }
    }

    func update(_ account: Account) {
        persistence.write(notifying: subject) { _ in entity(account.id)?.updateDetails(from: account) }
    }

    func apply(_ transfer: Transfer) {
        persistence.write(notifying: subject) { _ in
            mutate(transfer.from.id, by: -transfer.totalDebited)
            mutate(transfer.to.id, by: transfer.amount)
        }
    }

    func adjustBalance(of id: Account.ID, by delta: Double) {
        persistence.write(notifying: subject) { _ in mutate(id, by: delta) }
    }

    private func mutate(_ id: Account.ID, by delta: Double) {
        entity(id)?.netMovement += delta
    }

    private func entity(_ id: Account.ID) -> AccountEntity? {
        persistence.first(matching: #Predicate<AccountEntity> { $0.id == id })
    }
}

// MARK: - Transfers

final class SwiftDataTransferRepository: TransferRepositoryProtocol {

    static let shared = SwiftDataTransferRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchTransfers() -> [Transfer] {
        persistence.fetchAll(TransferEntity.self,
                             sortBy: [SortDescriptor(\TransferEntity.date, order: .reverse)]).map(\.domain)
    }

    func add(_ transfer: Transfer) {
        persistence.write(notifying: subject) { $0.insert(TransferEntity(transfer)) }
    }
}

// MARK: - People

final class SwiftDataPersonRepository: PersonRepositoryProtocol {

    static let shared = SwiftDataPersonRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchPeople() -> [Person] {
        persistence.fetchAll(PersonEntity.self).map(\.domain)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func person(id: Person.ID) -> Person? { entity(id)?.domain }

    func add(_ person: Person) {
        persistence.write(notifying: subject) { $0.insert(PersonEntity(person)) }
    }

    func update(_ person: Person) {
        persistence.write(notifying: subject) { _ in entity(person.id)?.update(from: person) }
    }

    func delete(id: Person.ID) {
        persistence.write(notifying: subject) { context in
            if let stored = entity(id) { context.delete(stored) }
        }
    }

    private func entity(_ id: Person.ID) -> PersonEntity? {
        persistence.first(matching: #Predicate<PersonEntity> { $0.id == id })
    }
}

// MARK: - Loans

final class SwiftDataLoanRepository: LoanRepositoryProtocol {

    static let shared = SwiftDataLoanRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchLoans() -> [Loan] {
        persistence.fetchAll(LoanEntity.self, sortBy: [SortDescriptor(\LoanEntity.createdAt)]).map(\.domain)
    }

    func loan(id: Loan.ID) -> Loan? { entity(id)?.domain }

    func add(_ loan: Loan) {
        persistence.write(notifying: subject) { context in
            let stored = LoanEntity(loan)
            context.insert(stored)
            stored.syncRepayments(loan.repayments, in: context)
        }
    }

    func update(_ loan: Loan) {
        persistence.write(notifying: subject) { context in
            entity(loan.id)?.update(from: loan, in: context)
        }
    }

    func delete(id: Loan.ID) {
        persistence.write(notifying: subject) { context in
            if let stored = entity(id) { context.delete(stored) }   // repayments cascade
        }
    }

    private func entity(_ id: Loan.ID) -> LoanEntity? {
        persistence.first(matching: #Predicate<LoanEntity> { $0.id == id })
    }
}

// MARK: - Savings

final class SwiftDataSavingsRepository: SavingsRepositoryProtocol {

    static let shared = SwiftDataSavingsRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchSavings() -> [SavingsAccount] {
        persistence.fetchAll(SavingsEntity.self, sortBy: [SortDescriptor(\SavingsEntity.createdAt)]).map(\.domain)
    }

    func savings(id: SavingsAccount.ID) -> SavingsAccount? { entity(id)?.domain }

    func add(_ savings: SavingsAccount) {
        persistence.write(notifying: subject) { context in
            let stored = SavingsEntity(savings)
            context.insert(stored)
            stored.syncEntries(savings.entries, in: context)
        }
    }

    func update(_ savings: SavingsAccount) {
        persistence.write(notifying: subject) { context in
            entity(savings.id)?.update(from: savings, in: context)
        }
    }

    func delete(id: SavingsAccount.ID) {
        persistence.write(notifying: subject) { context in
            if let stored = entity(id) { context.delete(stored) }   // entries cascade
        }
    }

    private func entity(_ id: SavingsAccount.ID) -> SavingsEntity? {
        persistence.first(matching: #Predicate<SavingsEntity> { $0.id == id })
    }
}

// MARK: - Categories

final class SwiftDataCategoryRepository: CategoryRepositoryProtocol {

    static let shared = SwiftDataCategoryRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchCategories(kind: CategoryKind) -> [TransactionCategory] {
        let key = kind.storageKey
        return persistence.fetchAll(CategoryEntity.self,
                                    matching: #Predicate<CategoryEntity> { $0.kindKey == key },
                                    sortBy: [SortDescriptor(\CategoryEntity.createdAt)]).map(\.domain)
    }

    func add(_ category: TransactionCategory) {
        persistence.write(notifying: subject) { $0.insert(CategoryEntity(category)) }
    }

    func update(_ category: TransactionCategory) {
        persistence.write(notifying: subject) { _ in entity(category.id)?.update(from: category) }
    }

    func delete(id: TransactionCategory.ID) {
        persistence.write(notifying: subject) { context in
            if let stored = entity(id) { context.delete(stored) }
        }
    }

    private func entity(_ id: TransactionCategory.ID) -> CategoryEntity? {
        persistence.first(matching: #Predicate<CategoryEntity> { $0.id == id })
    }
}

// MARK: - Income / expense

final class SwiftDataCashFlowRepository: CashFlowRepositoryProtocol {

    static let shared = SwiftDataCashFlowRepository()

    private let persistence: PersistenceController
    private let subject = PassthroughSubject<Void, Never>()

    init(persistence: PersistenceController = .shared) { self.persistence = persistence }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchEntries(kind: CategoryKind) -> [CashFlowEntry] {
        let key = kind.storageKey
        return persistence.fetchAll(CashFlowEntryEntity.self,
                                    matching: #Predicate<CashFlowEntryEntity> { $0.kindKey == key },
                                    sortBy: [SortDescriptor(\CashFlowEntryEntity.createdAt)]).map(\.domain)
    }

    func entry(id: CashFlowEntry.ID) -> CashFlowEntry? { entity(id)?.domain }

    func add(_ entry: CashFlowEntry) {
        persistence.write(notifying: subject) { $0.insert(CashFlowEntryEntity(entry)) }
    }

    func update(_ entry: CashFlowEntry) {
        persistence.write(notifying: subject) { _ in entity(entry.id)?.update(from: entry) }
    }

    func delete(id: CashFlowEntry.ID) {
        persistence.write(notifying: subject) { context in
            if let stored = entity(id) { context.delete(stored) }
        }
    }

    private func entity(_ id: CashFlowEntry.ID) -> CashFlowEntryEntity? {
        persistence.first(matching: #Predicate<CashFlowEntryEntity> { $0.id == id })
    }
}
