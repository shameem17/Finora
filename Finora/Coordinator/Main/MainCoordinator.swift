//
//  MainCoordinator.swift
//  finora
//
//  Created by Shameem on 8/2/26.
//

import UIKit
import SwiftUI

final class MainCoordinator: Coordinator {
    
    var rootViewController: UINavigationController?
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator]
    let settings: AppSettings
    
    init(settings: AppSettings) {
        let tabBarController = UITabBarController()
        tabBarController.selectedIndex = 0
        
        self.rootViewController = nil
        self.tabBarController = tabBarController
        self.childCoordinators = []
        self.settings = settings
    }
    
    func start() {
        childCoordinators.removeAll()
        
        for tab in AppTab.allCases {
            let coordinator = tab.coordinator(settings: settings)
            coordinator.start()
            setupTabBarItem(
                for: coordinator.rootViewController,
                title: tab.title,
                image: tab.unselectedtabBarImage,
                selectedImage: tab.selectedtabBarImage
            )
            childCoordinators.append(coordinator)
        }
        
        print("child coordinators count: \(childCoordinators.count)")
        tabBarController.viewControllers = childCoordinators.compactMap { $0.rootViewController }
    }
    
   
    
    // MARK: - Private Helpers
    
    private func selectTab(_ tab: AppTab, in allTabs: [AppTab]) {
        guard let index = allTabs.firstIndex(of: tab) else { return }
        tabBarController.selectedIndex = index
        
        // Pop to root on the selected tab's navigation stack for a clean state
        childCoordinators[index].rootViewController?.popToRootViewController(animated: false)
    }
    
    
    private func setupTabBarItem(for viewController: UIViewController?, title: String, image: String, selectedImage: String) {
        guard let viewController = viewController else { return }
        let unselectedImage = UIImage(systemName: image)
        let selectedImage = UIImage(systemName: selectedImage)
        let tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        viewController.tabBarItem = tabBarItem
    }
}



