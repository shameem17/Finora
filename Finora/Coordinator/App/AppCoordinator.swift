//
//  AppCoordinator.swift
//  finora
//
//  Created by Shameem on 7/30/26.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import os

class AppCoordinator: Coordinator {

    
    let window: UIWindow
    let settings: AppSettings
    var rootViewController: UINavigationController? = nil
    var childCoordinator: [Coordinator] = []
    
    var hasOnboarded: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var cancellables = Set<AnyCancellable>()
    
    /// Deep link received before the main flow was ready (e.g. cold launch).
    private var pendingDeepLink: DeepLink?
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.finora.app",
        category: "DeepLink"
    )
    
    init(window: UIWindow, settings: AppSettings) {
        self.window = window
        self.settings = settings
    }
    
    
    
    func start() {
        setupOnboardingStatus()
        
        hasOnboarded
            .removeDuplicates()
            .sink {[weak self] hasOnboarded in
            if hasOnboarded{
                self?.showMain()
            }else{
                self?.showOnboarding()
            }
        }.store(in: &cancellables)
    
        
      
    }
    
    
    private func showMain() {
        let mainCoordinator = MainCoordinator(settings: settings)
        mainCoordinator.start()
        childCoordinator.append(mainCoordinator)
        window.rootViewController = mainCoordinator.tabBarController //tabar is the root view controller of main coordinator
    }
    
    private func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(hasOnboarded: self.hasOnboarded)
        onboardingCoordinator.start()
        childCoordinator = [onboardingCoordinator]
        window.rootViewController = onboardingCoordinator.rootViewController
    }
    
    private func setupOnboardingStatus() {
        let key = "onboarding_status|finora"
        let value = UserDefaults.standard.bool(forKey: key)
        
        if value {
            hasOnboarded.send(true)
        }
        
        hasOnboarded
            .filter{ $0 }
            .sink { (value) in
                UserDefaults.standard.set(value, forKey: key)
            }.store(in: &self.cancellables)
    }
}


