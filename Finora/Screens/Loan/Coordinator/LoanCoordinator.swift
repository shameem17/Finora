//
//  LoanCoordinator.swift
//  Finora
//
//  Screens/Loan/Coordinator
//

import UIKit
import SwiftUI

final class LoanCoordinator: Coordinator {

    var rootViewController: UINavigationController?

    private let settings: AppSettings
    private let dependencies: LoanDependencies

    init(settings: AppSettings, dependencies: LoanDependencies? = nil) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.dependencies = dependencies ?? .live(isRemindersEnabled: { settings.notificationsEnabled })
    }

    func start() {
        let model = LoanViewModel(dependencies: dependencies)
        model.router = self

        let controller = UIHostingController(rootView: LoanView(model: model))
        rootViewController?.navigationBar.prefersLargeTitles = true
        rootViewController?.setViewControllers([controller], animated: false)
    }
}

// MARK: - LoanRouting

extension LoanCoordinator: LoanRouting {

    func showDetail(of loanID: Loan.ID) {
        let model = LoanDetailViewModel(loanID: loanID, dependencies: dependencies)
        model.router = self

        let controller = UIHostingController(rootView: LoanDetailView(model: model))
        rootViewController?.presentModal(controller)
    }

    func closeDetail() {
        rootViewController?.dismissModal()
    }
}
