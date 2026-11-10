//
//  OnboardingView.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI


struct OnboardingView<ViewModel: OnboardingViewModelProtocol>: View {
    let model: ViewModel
    
    @State private var selectedTabId: Int? = nil
  
    var body: some View {
        ZStack(alignment: .top) {
            model.currentModel?.bgcolorCode
            
            WaveShape(amplitude: 20, frequency: 1.0, phase: 0 , baseline: 0.52)
                .fill(Color.white.opacity(0.9))
            
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: model.currentModel?.id)
            
            HStack {
                Spacer()
                skipButton
            }
            .frame(alignment: .topTrailing)
            .padding(.top, 80)
            .padding(.trailing)
            .zIndex(2)
            
            VStack {
                Spacer()
                    .frame(height: 50)
                
                TabView(selection: $selectedTabId) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        OnboardingCard(data: step.model){
                            withAnimation(.easeInOut(duration: 0.5)) {
                                model.next()
                                selectedTabId = model.currentModel?.id
                            }
                        }
                        .tag(step.model.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .highPriorityGesture(
                    DragGesture()
                        .onEnded { value in
                            let horizontalDrag = value.translation.width
                            let threshold: CGFloat = 50
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if horizontalDrag > threshold {
                                    model.previous()
                                    selectedTabId = model.currentModel?.id
                                } else if horizontalDrag < -threshold {
                                    model.next()
                                    selectedTabId = model.currentModel?.id
                                }
                            }
                        }
                )
                
                Spacer()
                    .frame(height: 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        
        .onAppear {
            selectedTabId = model.currentModel?.id
        }
        .onChange(of: model.currentModel?.id) { _, newId in
            selectedTabId = newId
        }
    }
}

extension OnboardingView {
    var skipButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                model.next()
                selectedTabId = model.currentModel?.id
            }
        }) {
            Text("Skip")
                .font(.manrope, size: 20, weight: .bold)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color(hex: "#FF6347"))
                .clipShape(Capsule())
        }
    }
}


#Preview {
    OnboardingView(model: OnboardingViewModel())
}
