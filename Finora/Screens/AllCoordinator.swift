//
//  HomeCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation
import UIKit
import SwiftUI



class SettingsCoordinator: Coordinator {
    var rootViewController: UINavigationController?
    
    let settings: AppSettings
    
    lazy var settingsView: UIViewController = {
        let view = SettingsView().environment(\.appSettings, settings)
        let vc = UIHostingController(rootView: view)
        return vc
    }()
    
    init(settings: AppSettings) {
        self.rootViewController = UINavigationController()
        self.settings = settings
    }
    
    func start() {
        rootViewController?.navigationBar.prefersLargeTitles = true
        rootViewController?.setViewControllers([settingsView], animated: false)
    }
    
    
}
