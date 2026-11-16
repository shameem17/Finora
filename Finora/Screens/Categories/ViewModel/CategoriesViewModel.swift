//
//  CategoriesViewModel.swift
//  Finora
//
//  Screens/Categories/ViewModel
//

import Foundation
import Observation
import Combine

protocol CategoriesViewModelProtocol: AnyObject, Observable {
    var kind: CategoryKind { get set }
    var categories: [TransactionCategory] { get }
    var totalBudget: Double { get }
    var budgetedCount: Int { get }
    func load()
    func makeFormViewModel(editing category: TransactionCategory?) -> CategoryFormViewModel
}

@Observable
final class CategoriesViewModel: CategoriesViewModelProtocol {

    var kind: CategoryKind = .expense {
        didSet { if oldValue != kind { reload() } }
    }

    private(set) var categories: [TransactionCategory] = []

    var totalBudget: Double { categories.compactMap(\.monthlyBudget).reduce(0, +) }
    var budgetedCount: Int { categories.filter { $0.monthlyBudget != nil }.count }

    @ObservationIgnored private let repository: CategoryRepositoryProtocol
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
        reload()
        repository.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.reload() }
            .store(in: &cancellables)
    }

    func load() { reload() }

    func makeFormViewModel(editing category: TransactionCategory?) -> CategoryFormViewModel {
        CategoryFormViewModel(mode: category.map { .edit($0) } ?? .create(kind: kind),
                              repository: repository)
    }

    private func reload() {
        categories = repository.fetchCategories(kind: kind)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
