//
//  SavingsRepository.swift
//  Finora
//
//  Screens/Savings/Repository
//

import Foundation
import Combine

protocol SavingsRepositoryProtocol: AnyObject {
    /// Emits after every mutation so screens can refresh without polling.
    var changes: AnyPublisher<Void, Never> { get }

    func fetchSavings() -> [SavingsAccount]
    func savings(id: SavingsAccount.ID) -> SavingsAccount?
    func add(_ savings: SavingsAccount)
    func update(_ savings: SavingsAccount)
    func delete(id: SavingsAccount.ID)
}

/// In-memory implementation. Swap for SwiftData / Core Data later without
/// touching any view model.
final class InMemorySavingsRepository: SavingsRepositoryProtocol {

    static let shared = InMemorySavingsRepository()

    private var items: [SavingsAccount]
    private let subject = PassthroughSubject<Void, Never>()

    init(savings: [SavingsAccount] = []) {
        self.items = savings
    }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchSavings() -> [SavingsAccount] { items }

    func savings(id: SavingsAccount.ID) -> SavingsAccount? {
        items.first { $0.id == id }
    }

    func add(_ savings: SavingsAccount) {
        items.append(savings)
        subject.send()
    }

    func update(_ savings: SavingsAccount) {
        guard let index = items.firstIndex(where: { $0.id == savings.id }) else { return }
        items[index] = savings
        subject.send()
    }

    func delete(id: SavingsAccount.ID) {
        items.removeAll { $0.id == id }
        subject.send()
    }
}
