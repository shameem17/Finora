//
//  AccountsCoordinator.swift
//  Finora
//
//  Screens/Accounts/Coordinator
//

import UIKit
import SwiftUI

final class AccountsCoordinator: Coordinator {

    var rootViewController: UINavigationController?

    private let settings: AppSettings
    private let repository: AccountRepositoryProtocol

    init(settings: AppSettings,
         repository: AccountRepositoryProtocol = InMemoryAccountRepository.shared) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.repository = repository
    }

    func start() {
        let model = AccountsViewModel(repository: repository)
        let controller = UIHostingController(rootView: AccountsView(model: model).environment(\.appSettings, settings))
        rootViewController?.navigationBar.prefersLargeTitles = true
        rootViewController?.setViewControllers([controller], animated: false)
    }
}
