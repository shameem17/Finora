//
//  SavingsCoordinator.swift
//  Finora
//
//  Screens/Savings/Coordinator
//

import UIKit
import SwiftUI

final class SavingsCoordinator: Coordinator {

    var rootViewController: UINavigationController?

    private let settings: AppSettings
    private let dependencies: SavingsDependencies

    init(settings: AppSettings, dependencies: SavingsDependencies? = nil) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.dependencies = dependencies ?? .live()
    }

    func start() {
        let model = SavingsViewModel(dependencies: dependencies)
        model.router = self

        let controller = UIHostingController(rootView: SavingsView(model: model))
        rootViewController?.navigationBar.prefersLargeTitles = true
        rootViewController?.setViewControllers([controller], animated: false)
    }
}

extension SavingsCoordinator: SavingsRouting {

    func showDetail(of id: SavingsAccount.ID) {
        let model = SavingsDetailViewModel(savingsID: id, dependencies: dependencies)
        model.router = self

        let controller = UIHostingController(rootView: SavingsDetailView(model: model))
        controller.hidesBottomBarWhenPushed = true
        controller.navigationItem.largeTitleDisplayMode = .never
        rootViewController?.pushViewController(controller, animated: true)
    }

    func showLog(of id: SavingsAccount.ID?) {
        let model = SavingsLogViewModel(scope: id, dependencies: dependencies)

        let controller = UIHostingController(rootView: SavingsLogView(model: model))
        controller.hidesBottomBarWhenPushed = true
        controller.navigationItem.largeTitleDisplayMode = .never
        rootViewController?.pushViewController(controller, animated: true)
    }

    func closeDetail() {
        rootViewController?.popViewController(animated: true)
    }
}
