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
    
    lazy var incomeView: UIViewController = {
        let view = IncomeView()
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
    }
    
    func start() {
        rootViewController?.setViewControllers([incomeView], animated: false)
    }
    
    
}
