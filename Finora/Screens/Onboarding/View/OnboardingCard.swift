//
//  OnboardingCard.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI

struct OnboardingCard: View {
    
    var data: OnboardingModel
    let nextAction: () -> Void
    
    var body: some View {
        VStack{
            
            Image(data.imageName)
                .resizable()
                .frame(maxWidth: .infinity)
                .scaledToFit()
                .containerRelativeFrame(.vertical) { length, axis in
                    length * 0.40
                }
                .padding(.top, 30)
            
            VStack(alignment: .leading){
                
                Text(data.title)
                    .font(.manrope, size: 56, weight: .extraBold)
                    .fontWeight(.bold)
                    .foregroundColor(data.titleColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom)
                    .padding(.top, 35)
                
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
        HStack{
            Button {
                nextAction()
            } label: {
                Text(data.button.title)
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
            
            Spacer()
            
            
            Text(data.shortNote)
                .font(.manrope, size: 12, weight: .regular)
                .foregroundColor(.customBlack)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
            
        }
        
    }
}
