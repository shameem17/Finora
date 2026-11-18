//
//  CashFlowViewModel.swift
//  Finora
//
//  Screens/CashFlow/ViewModel
//
//  Drives both the Income and the Expense screen; only `kind` differs.
//

import Foundation
import SwiftUI
import Combine
import Observation

protocol CashFlowViewModelProtocol: AnyObject, Observable {
    var kind: CategoryKind { get }
    var period: ReportPeriod { get set }
    /// One slice per category for the chosen period, largest first.
    var items: [BreakdownItem] { get }
    /// Entries of the chosen period, newest first.
    var entries: [CashFlowItem] { get }
    var total: Double { get }

    func load()
    func makeFormViewModel(editing entry: CashFlowEntry?) -> CashFlowFormViewModel
}

@Observable
final class CashFlowViewModel: CashFlowViewModelProtocol {

    let kind: CategoryKind

    var period: ReportPeriod = .month {
        didSet { if oldValue != period { rebuild() } }
    }

    private(set) var items: [BreakdownItem] = []
    private(set) var entries: [CashFlowItem] = []
    private(set) var total: Double = 0

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private let dependencies: CashFlowDependencies

    init(kind: CategoryKind, dependencies: CashFlowDependencies) {
        self.kind = kind
        self.dependencies = dependencies

        dependencies.entries.changes
            .merge(with: dependencies.categories.changes, dependencies.accounts.changes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.rebuild() }
            .store(in: &cancellables)

        rebuild()
    }

    func load() { rebuild() }

    func makeFormViewModel(editing entry: CashFlowEntry?) -> CashFlowFormViewModel {
        CashFlowFormViewModel(mode: entry.map { .edit($0) } ?? .create(kind: kind),
                              dependencies: dependencies)
    }

    private func rebuild() {
        let categories = Dictionary(uniqueKeysWithValues:
            dependencies.categories.fetchCategories(kind: kind).map { ($0.id, $0) })
        let accounts = Dictionary(uniqueKeysWithValues:
            dependencies.accounts.fetchAccounts().map { ($0.id, AccountSummary($0)) })

        let inPeriod = dependencies.entries.fetchEntries(kind: kind)
            .filter { period.contains($0.date) }
            .sorted { $0.date > $1.date }

        entries = inPeriod.map {
            CashFlowItem(entry: $0, category: categories[$0.categoryID], account: accounts[$0.accountID])
        }
        total = inPeriod.reduce(0) { $0 + $1.amount }

        let byCategory = Dictionary(grouping: inPeriod, by: \.categoryID)
        items = byCategory.map { id, group in
            let amount = group.reduce(0) { $0 + $1.amount }
            if let category = categories[id] {
                return BreakdownItem(name: category.name, amount: amount,
                                     color: Color(hex: category.tint), icon: category.icon)
            }
            return BreakdownItem(name: "Uncategorised", amount: amount,
                                 color: Color.textTertiary, icon: "questionmark.circle")
        }
        .sorted { $0.amount > $1.amount }
    }
}
