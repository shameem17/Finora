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
    let onBoardingDone: () -> Void
    
    let pages: [OnboardingStep: OnboardingModel] =
    Dictionary(
        uniqueKeysWithValues: OnboardingStep.allCases.map {
            ($0, $0.model)
        }
    )
    
    init(onBoardingDone: @escaping () -> Void = {}) {
        self.onBoardingDone = onBoardingDone
    }
    
    var currentModel: OnboardingModel? {
        pages[currentStep]
    }
    
    var isLastPage: Bool {
        currentStep.isLast
    }
    
    func next() {
        switch currentStep {
        case .first: currentStep = .second
        case .second: currentStep = .third
        case .third: onBoardingDone()
        }
        
    }
    
    func previous() {
        guard let previousStep = currentStep.previous else {
            return
        }
        currentStep = previousStep
    }
    
    func skip() {
        onBoardingDone()
    }
    
    func onboardingCompleted(){
        onBoardingDone()
    }
}
