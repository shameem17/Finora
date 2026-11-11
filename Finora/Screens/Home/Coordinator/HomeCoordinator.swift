//
//  HomeCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import UIKit
import SwiftUI

class HomeCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    let settings: AppSettings
    let viewModel: HomeViewModel
    
    lazy var homeVC: UIViewController = {
        let view = HomeView(model: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
        self.viewModel = HomeViewModel()
    }
    
    func start() {
        print("start HomeCoordinator. rootViewController: \(rootViewController == nil)")
        rootViewController?.setViewControllers([homeVC], animated: false)
    }
    
    
}

