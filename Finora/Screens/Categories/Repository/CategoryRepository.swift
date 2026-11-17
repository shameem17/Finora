//
//  CategoryRepository.swift
//  Finora
//
//  Screens/Categories/Repository
//

import Foundation
import Combine

protocol CategoryRepositoryProtocol: ChangeNotifying {
    func fetchCategories(kind: CategoryKind) -> [TransactionCategory]
    func add(_ category: TransactionCategory)
    func update(_ category: TransactionCategory)
    func delete(id: TransactionCategory.ID)
}

final class InMemoryCategoryRepository: CategoryRepositoryProtocol {

    static let shared = InMemoryCategoryRepository()

    private let store: InMemoryStore<TransactionCategory>

    init(categories: [TransactionCategory] = TransactionCategory.defaults) {
        store = InMemoryStore(categories)
    }

    var changes: AnyPublisher<Void, Never> { store.changes }

    func fetchCategories(kind: CategoryKind) -> [TransactionCategory] {
        store.items.filter { $0.kind == kind }
    }

    func add(_ category: TransactionCategory) { store.add(category) }
    func update(_ category: TransactionCategory) { store.update(category) }
    func delete(id: TransactionCategory.ID) { store.remove(id: id) }
}
