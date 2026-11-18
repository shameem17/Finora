//
//  ExpenseCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/15/26.
//

import UIKit
import SwiftUI



class ExpenseCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    private let dependencies: CashFlowDependencies
    
    lazy var expenseView: UIViewController = {
        let model = CashFlowViewModel(kind: .expense, dependencies: dependencies)
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
        rootViewController?.setViewControllers([expenseView], animated: false)
    }
    
    
}
