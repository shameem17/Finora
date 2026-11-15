//
//  HomeCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation
import UIKit
import SwiftUI



class LoanCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    lazy var loanView: UIViewController = {
        let view = LoanView()
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
    }
    
    func start() {
        rootViewController?.setViewControllers([loanView], animated: false)
    }
    
    
}


class SettingsCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    lazy var settingsView: UIViewController = {
        let view = SettingsView()
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
    }
    
    func start() {
        rootViewController?.setViewControllers([settingsView], animated: false)
    }
    
    
}
