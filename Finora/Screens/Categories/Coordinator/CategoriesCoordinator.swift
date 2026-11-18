//
//  CategoriesCoordinator.swift
//  Finora
//
//  Screens/Categories/Coordinator
//

import UIKit
import SwiftUI

final class CategoriesCoordinator: Coordinator {

    var rootViewController: UINavigationController?

    private let settings: AppSettings
    private let repository: CategoryRepositoryProtocol

    init(settings: AppSettings,
         repository: CategoryRepositoryProtocol = SwiftDataCategoryRepository.shared) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.repository = repository
    }

    func start() {
        let model = CategoriesViewModel(repository: repository)
        let controller = UIHostingController(rootView: CategoriesView(model: model))
        rootViewController?.navigationBar.prefersLargeTitles = true
        rootViewController?.setViewControllers([controller], animated: false)
    }
}
