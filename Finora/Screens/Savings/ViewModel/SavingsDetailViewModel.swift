//
//  SavingsDetailViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//

import Foundation
import Combine
import Observation

protocol SavingsDetailViewModelProtocol: AnyObject, Observable {
    /// `nil` once the savings account no longer exists.
    var item: SavingsItem? { get }
    /// Newest first.
    var entries: [SavingsEntry] { get }

    func load()
    func makeEntryFormViewModel(kind: SavingsEntryKind) -> SavingsEntryFormViewModel?
    func makeEditEntryFormViewModel(_ entry: SavingsEntry) -> SavingsEntryFormViewModel?
    func makeEditFormViewModel() -> SavingsFormViewModel?
    func deleteEntry(id: SavingsEntry.ID) -> Bool
    func deleteSavings(returnRemaining: Bool)
}

@Observable
final class SavingsDetailViewModel: SavingsDetailViewModelProtocol {

    private(set) var item: SavingsItem?
    private(set) var entries: [SavingsEntry] = []

    @ObservationIgnored weak var router: SavingsRouting?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    private let savingsID: SavingsAccount.ID
    private let dependencies: SavingsDependencies

    init(savingsID: SavingsAccount.ID, dependencies: SavingsDependencies) {
        self.savingsID = savingsID
        self.dependencies = dependencies

        dependencies.savings.changes
            .merge(with: dependencies.accounts.changes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    func load() {
        guard let savings = dependencies.savings.savings(id: savingsID) else {
            item = nil
            entries = []
            return
        }
        item = SavingsItem(savings: savings,
                           account: dependencies.accounts.account(id: savings.accountID).map(AccountSummary.init))
        entries = savings.sortedEntries
    }

    func makeEntryFormViewModel(kind: SavingsEntryKind) -> SavingsEntryFormViewModel? {
        guard let savings = item?.savings else { return nil }
        return SavingsEntryFormViewModel(mode: .create(kind), savings: savings, dependencies: dependencies)
    }

    func makeEditEntryFormViewModel(_ entry: SavingsEntry) -> SavingsEntryFormViewModel? {
        guard let savings = item?.savings else { return nil }
        return SavingsEntryFormViewModel(mode: .edit(entry), savings: savings, dependencies: dependencies)
    }

    func makeEditFormViewModel() -> SavingsFormViewModel? {
        guard let savings = item?.savings else { return nil }
        return SavingsFormViewModel(mode: .edit(savings), dependencies: dependencies)
    }

    @discardableResult
    func deleteEntry(id: SavingsEntry.ID) -> Bool {
        dependencies.service.deleteEntry(id: id, from: savingsID)
    }

    func deleteSavings(returnRemaining: Bool) {
        dependencies.service.delete(savingsID: savingsID, returnRemaining: returnRemaining)
        router?.closeDetail()
    }
}
