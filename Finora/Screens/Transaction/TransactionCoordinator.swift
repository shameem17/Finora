//
//  Coordinator.swift
//  Finora
//
//  Created by Shameem on 11/15/26.
//

import SwiftUI
import UIKit

class TransactionCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    let viewModel: TransactionViewModel
    
    lazy var transactionView: UIViewController = {
        let view = TransactionView(model: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings,
         accountRepository: AccountRepositoryProtocol = InMemoryAccountRepository.shared,
         transferRepository: TransferRepositoryProtocol = InMemoryTransferRepository.shared) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.viewModel = TransactionViewModel(accountRepository: accountRepository,
                                              transferRepository: transferRepository)
    }
    
    func start() {
        rootViewController?.setViewControllers([transactionView], animated: false)
    }
    
    
}
