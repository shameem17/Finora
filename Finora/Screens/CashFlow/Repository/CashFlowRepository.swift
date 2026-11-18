//
//  CashFlowRepository.swift
//  Finora
//
//  Screens/CashFlow/Repository
//

import Foundation
import Combine

protocol CashFlowRepositoryProtocol: ChangeNotifying {
    func fetchEntries(kind: CategoryKind) -> [CashFlowEntry]
    func entry(id: CashFlowEntry.ID) -> CashFlowEntry?
    func add(_ entry: CashFlowEntry)
    func update(_ entry: CashFlowEntry)
    func delete(id: CashFlowEntry.ID)
}

/// In-memory implementation. Swap for SwiftData / Core Data later without
/// touching any view model.
final class InMemoryCashFlowRepository: CashFlowRepositoryProtocol {

    static let shared: InMemoryCashFlowRepository = {
        #if DEBUG
        let entries = CashFlowSampleData.entries(
            categories: CategoryKind.allCases.flatMap { InMemoryCategoryRepository.shared.fetchCategories(kind: $0) },
            accounts: InMemoryAccountRepository.shared.fetchAccounts()
        )
        return InMemoryCashFlowRepository(entries: entries)
        #else
        return InMemoryCashFlowRepository()
        #endif
    }()

    private let store: InMemoryStore<CashFlowEntry>

    init(entries: [CashFlowEntry] = []) {
        store = InMemoryStore(entries)
    }

    var changes: AnyPublisher<Void, Never> { store.changes }

    func fetchEntries(kind: CategoryKind) -> [CashFlowEntry] {
        store.items.filter { $0.kind == kind }
    }

    func entry(id: CashFlowEntry.ID) -> CashFlowEntry? { store.item(id: id) }
    func add(_ entry: CashFlowEntry) { store.add(entry) }
    func update(_ entry: CashFlowEntry) { store.update(entry) }
    func delete(id: CashFlowEntry.ID) { store.remove(id: id) }
}
