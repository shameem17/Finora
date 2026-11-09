//
//  OnboardingCard.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI

struct OnboardingCard: View {
    
    var data: OnboardingModel
    
    
    var body: some View {
        VStack{
        
           Spacer()
                .frame(height: 30)
            
            Image(data.imageName)
                .resizable()
                .frame(maxWidth: .infinity)
                .scaledToFit()
                .containerRelativeFrame(.vertical) { length, axis in
                    length * 0.40
                }
                .background(
                    Circle()
                        .fill(Color.brandOrange.opacity(0.3))
                )
            
            VStack(alignment: .leading){
                
                Text(data.title)
                    .font(.manrope, size: 56, weight: .extraBold)
                    .fontWeight(.bold)
                    .foregroundColor(data.titleColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom)
                
                Text(data.description)
                    .font(.manrope, size: 20, weight: .bold)
                    .foregroundColor(data.descriptionColor)
                    .multilineTextAlignment(.leading)
                   
                Spacer()
                nextButton
                
                Spacer()

            }
                
        }
        .padding()
    }
}

extension OnboardingCard{
    var nextButton: some View{
        Button {
            
        } label: {
            Text(data.buttonTitle)
                .font(.manrope, size: 20, weight: .extraBold)
                .foregroundColor(.white)
        }
        .padding(10)
        .padding(.horizontal)
        .background(data.titleColor)
        .clipShape(
                Capsule()
        )
        .padding(.trailing, 4)
        .padding(.bottom, 4)
        .background(Color.yellow)
        .clipShape(
                Capsule()
        )
        .shadow(color: Color.yellow.opacity(0.8), radius: 4, x: 0, y: 4)
    }
}
