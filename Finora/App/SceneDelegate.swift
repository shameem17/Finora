//
//  SceneDelegate.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let windoSecene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windoSecene)
        let settings = AppSettings()
        
        let appCoordinator = AppCoordinator(window: window,
                                            settings: settings)
        appCoordinator.start()
        
        self.appCoordinator = appCoordinator
      
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

