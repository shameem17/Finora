//
//  SavingsLogViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//

import Foundation
import Combine
import Observation

protocol SavingsLogViewModelProtocol: AnyObject, Observable {
    var filter: SavingsLogFilter { get set }
    /// Name of the savings account the log is limited to; `nil` for all savings.
    var scopeTitle: String? { get }
    var sections: [SavingsLogSection] { get }
    var totalAdded: Double { get }
    var totalWithdrawn: Double { get }
    var isEmpty: Bool { get }
    func load()
}

@Observable
final class SavingsLogViewModel: SavingsLogViewModelProtocol, Identifiable {

    let id = UUID()

    var filter: SavingsLogFilter = .all {
        didSet { if oldValue != filter { rebuild() } }
    }

    private(set) var scopeTitle: String?
    private(set) var sections: [SavingsLogSection] = []
    private(set) var totalAdded: Double = 0
    private(set) var totalWithdrawn: Double = 0
    private(set) var isEmpty = true

    @ObservationIgnored private var all: [SavingsLogEntry] = []
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private let scope: SavingsAccount.ID?
    private let dependencies: SavingsDependencies

    init(scope: SavingsAccount.ID? = nil, dependencies: SavingsDependencies) {
        self.scope = scope
        self.dependencies = dependencies

        dependencies.savings.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    func load() {
        var source = dependencies.savings.fetchSavings()
        if let scope { source = source.filter { $0.id == scope } }
        scopeTitle = scope == nil ? nil : source.first?.name

        all = source.flatMap { savings in
            savings.entries.map { SavingsLogEntry(entry: $0, savingsID: savings.id, savingsName: savings.name) }
        }
        isEmpty = all.isEmpty
        rebuild()
    }

    private func rebuild() {
        let visible = all.filter { filter.includes($0.entry.kind) }
        sections = SavingsLogSection.make(from: visible)
        totalAdded = visible.lazy.filter { $0.entry.kind == .deposit }.reduce(0) { $0 + $1.entry.amount }
        totalWithdrawn = visible.lazy.filter { $0.entry.kind == .withdrawal }.reduce(0) { $0 + $1.entry.amount }
    }
}
