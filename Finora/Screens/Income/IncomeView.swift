//
//  IncomeView.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI


// MARK: - Screen

struct IncomeView: View {
    @State private var model: IncomeViewModel

    init(model: IncomeViewModel = IncomeViewModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PillPicker(selection: $model.period)

                        DonutCard(title: "Total Income",
                                  subtitle: model.period.subtitle,
                                  centerCaption: "Earned",
                                  items: model.items)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Income")
            .safeAreaInset(edge: .bottom) {
                AddActionButton(title: "Add New") {
                    // add new income
                }
            }
        }
    }
}


#Preview {
    IncomeView()
}
