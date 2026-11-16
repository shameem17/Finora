//
//  CategoryRepository.swift
//  Finora
//
//  Screens/Categories/Repository
//

import Foundation
import Combine

protocol CategoryRepositoryProtocol: AnyObject {
    var changes: AnyPublisher<Void, Never> { get }
    func fetchCategories(kind: CategoryKind) -> [TransactionCategory]
    func add(_ category: TransactionCategory)
    func update(_ category: TransactionCategory)
    func delete(id: TransactionCategory.ID)
}

final class InMemoryCategoryRepository: CategoryRepositoryProtocol {

    static let shared = InMemoryCategoryRepository()

    private var categories: [TransactionCategory]
    private let subject = PassthroughSubject<Void, Never>()

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(categories: [TransactionCategory] = TransactionCategory.defaults) {
        self.categories = categories
    }

    func fetchCategories(kind: CategoryKind) -> [TransactionCategory] {
        categories.filter { $0.kind == kind }
    }

    func add(_ category: TransactionCategory) {
        categories.append(category)
        subject.send()
    }

    func update(_ category: TransactionCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        subject.send()
    }

    func delete(id: TransactionCategory.ID) {
        categories.removeAll { $0.id == id }
        subject.send()
    }
}
