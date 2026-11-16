//
//  AccountsViewModel.swift
//  Finora
//
//  Screens/Accounts/ViewModel
//

import Foundation
import Combine
import Observation

protocol AccountsViewModelProtocol: AnyObject, Observable {
    var accounts: [Account] { get }
    var totalBalance: Double { get }

    func load()
    func makeFormViewModel(editing account: Account?) -> AccountFormViewModel
}

@Observable
final class AccountsViewModel: AccountsViewModelProtocol {

    private(set) var accounts: [Account] = []

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private let repository: AccountRepositoryProtocol

    init(repository: AccountRepositoryProtocol) {
        self.repository = repository

        repository.changes
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    func load() {
        accounts = repository.fetchAccounts()
    }

    func makeFormViewModel(editing account: Account?) -> AccountFormViewModel {
        AccountFormViewModel(mode: account.map { .edit($0) } ?? .create, repository: repository)
    }
}
