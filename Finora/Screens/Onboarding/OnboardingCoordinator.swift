//
//  OnboardingCoordinator.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import UIKit
import SwiftUI
import Combine

class OnboardingCoordinator: Coordinator {
    
    var rootViewController: UINavigationController?
    
    var hasOnboarded: CurrentValueSubject<Bool, Never>
    
    init(rootViewController: UINavigationController? = nil,
         hasOnboarded: CurrentValueSubject<Bool, Never>) {
        self.rootViewController = rootViewController
        self.hasOnboarded = hasOnboarded
    }
    
    func start() {
        let viewModel = OnboardingViewModel(){[weak self] in
            self?.hasOnboarded.send(true)
        }
        let view = OnboardingView(model: viewModel)
        let vc = UIHostingController(rootView: view)
        rootViewController = UINavigationController(rootViewController: vc)
    }
    
    
}
