//
//  Expense.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI

struct ExpenseView: View {
    @State private var model: ExpenseViewModel

    init(model: ExpenseViewModel = ExpenseViewModel()) {
        _model = State(initialValue: model)
    }
    
   var body: some View {
       
           @Bindable var model = model

          // NavigationStack {
               ZStack {
                   Color.appBackground.ignoresSafeArea()

                   ScrollView(showsIndicators: false) {
                       VStack(spacing: 20) {
                           PillPicker(selection: $model.period)

                           DonutCard(title: "Total Expense",
                                     subtitle: model.period.subtitle,
                                     centerCaption: "Expense",
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
          // }
       
    }
}


#Preview {
    ExpenseView()
}
