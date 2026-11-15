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
    
    lazy var expenseView: UIViewController = {
        let view = ExpenseView()
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
    }
    
    func start() {
        rootViewController?.setViewControllers([expenseView], animated: false)
    }
    
    
}
