//
//  HomeCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}


class IncomeCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}


class ExpenseCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}


class TransactionCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}

class LoanCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}


class SettingsCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    init(rootViewController: UINavigationController? = nil,
         settings: AppSettings) {
        self.rootViewController = rootViewController
        self.settings = settings
    }
    
    func start() {
        
    }
    
    
}
