//
//  OnboardingCard.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI

struct OnboardingCard: View {
    
    var data: OnboardingModel?
    
    
    var body: some View {
            VStack{
                Text(data?.title ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(data?.description ?? "")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
            }.background(
                Color(hex: data?.bgcolorCode).ignoresSafeArea()
            )
    }
}
