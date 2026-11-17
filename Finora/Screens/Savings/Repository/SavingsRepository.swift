//
//  SavingsRepository.swift
//  Finora
//
//  Screens/Savings/Repository
//

import Foundation
import Combine

protocol SavingsRepositoryProtocol: ChangeNotifying {
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

    private let store: InMemoryStore<SavingsAccount>

    init(savings: [SavingsAccount] = []) {
        store = InMemoryStore(savings)
    }

    var changes: AnyPublisher<Void, Never> { store.changes }

    func fetchSavings() -> [SavingsAccount] { store.items }
    func savings(id: SavingsAccount.ID) -> SavingsAccount? { store.item(id: id) }
    func add(_ savings: SavingsAccount) { store.add(savings) }
    func update(_ savings: SavingsAccount) { store.update(savings) }
    func delete(id: SavingsAccount.ID) { store.remove(id: id) }
}
