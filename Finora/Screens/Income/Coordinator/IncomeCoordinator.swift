//
//  IncomeCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import SwiftUI
import UIKit

class IncomeCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    let settings: AppSettings
    private let dependencies: CashFlowDependencies
    
    lazy var incomeView: UIViewController = {
        let model = CashFlowViewModel(kind: .income, dependencies: dependencies)
        let view = CashFlowView(model: model)
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.dependencies = .live()
    }
    
    func start() {
        rootViewController?.setViewControllers([incomeView], animated: false)
    }
    
    
}
