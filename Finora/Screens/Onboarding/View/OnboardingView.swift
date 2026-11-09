//
//  OnboardingView.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI


struct OnboardingView<ViewModel: OnboardingViewModelProtocol>:  View {
    let model: ViewModel
    let onBoardingDone: () -> Void
    
    var body: some View {
        ZStack(alignment: .top){
            Color(hex: model.currentModel?.bgcolorCode).ignoresSafeArea()
            
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                OnboardingCard(data: model.currentModel)
            }
            
            
        }.ignoresSafeArea()
        
    }
}
// #F7D8D3
// #F4FDDF
// #FEE6D3
