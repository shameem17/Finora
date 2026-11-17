//
//  SavingsViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//

import Foundation
import Combine
import Observation

protocol SavingsViewModelProtocol: AnyObject, Observable {
    var items: [SavingsItem] { get }
    var summary: SavingsSummary { get }

    func load()
    func showDetail(of id: SavingsAccount.ID)
    func makeLogViewModel() -> SavingsLogViewModel
    func makeFormViewModel() -> SavingsFormViewModel
    func makeEntryFormViewModel(for id: SavingsAccount.ID, kind: SavingsEntryKind) -> SavingsEntryFormViewModel?
}

@Observable
final class SavingsViewModel: SavingsViewModelProtocol {

    private(set) var items: [SavingsItem] = []
    private(set) var summary: SavingsSummary = .empty

    @ObservationIgnored weak var router: SavingsRouting?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private let dependencies: SavingsDependencies

    init(dependencies: SavingsDependencies) {
        self.dependencies = dependencies

        dependencies.savings.changes
            .merge(with: dependencies.accounts.changes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    func load() {
        let accounts = dependencies.accounts.fetchAccounts()
        let savings = dependencies.savings.fetchSavings()

        items = savings
            .sorted { $0.currentSavings > $1.currentSavings }
            .map { saving in
                SavingsItem(savings: saving,
                            account: accounts.first { $0.id == saving.accountID }.map(AccountSummary.init))
            }
        summary = SavingsSummary.make(savings: savings, accounts: accounts)
    }

    func showDetail(of id: SavingsAccount.ID) {
        router?.showDetail(of: id)
    }

    func makeLogViewModel() -> SavingsLogViewModel {
        SavingsLogViewModel(dependencies: dependencies)
    }

    func makeFormViewModel() -> SavingsFormViewModel {
        SavingsFormViewModel(mode: .create, dependencies: dependencies)
    }

    func makeEntryFormViewModel(for id: SavingsAccount.ID, kind: SavingsEntryKind) -> SavingsEntryFormViewModel? {
        guard let savings = dependencies.savings.savings(id: id) else { return nil }
        return SavingsEntryFormViewModel(mode: .create(kind), savings: savings, dependencies: dependencies)
    }
}
