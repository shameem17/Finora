//
//  OnboardingViewModel.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import Foundation
import Combine

protocol OnboardingViewModelProtocol: AnyObject{
    func next()
    func previous()
    func skip()
    var currentModel: OnboardingModel? { get }
}


@Observable
final class OnboardingViewModel: OnboardingViewModelProtocol {
    
    private(set) var currentStep: OnboardingStep = .first
    
    let pages: [OnboardingStep: OnboardingModel] =
    Dictionary(
        uniqueKeysWithValues: OnboardingStep.allCases.map {
            ($0, $0.model)
        }
    )
    
    var currentModel: OnboardingModel? {
        pages[currentStep]
    }
    
    var isLastPage: Bool {
        currentStep.isLast
    }
    
    func next() {
        guard let nextStep = currentStep.next else {
            return
        }
        currentStep = nextStep
    }
    
    func previous() {
        guard let previousStep = currentStep.previous else {
            return
        }
        currentStep = previousStep
    }
    
    func skip() {
        currentStep = .third
    }
}
