//
//  CategoriesView.swift
//  Finora
//
//  Screens/Categories/View
//

import SwiftUI

struct CategoriesView<ViewModel: CategoriesViewModelProtocol>: View {

    @Bindable var model: ViewModel
    @State private var form: CategoryFormViewModel?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    PillPicker(selection: $model.kind)
                        .padding(.bottom, 4)

                    if model.kind == .expense { summaryCard }

                    if model.categories.isEmpty {
                        emptyState
                    } else {
                        ForEach(model.categories) { category in
                            Button {
                                form = model.makeFormViewModel(editing: category)
                            } label: {
                                CategoryRow(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .animation(.smooth, value: model.kind)
            }
        }
        .navigationTitle("Categories")
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: "Add \(model.kind.title) Category") {
                form = model.makeFormViewModel(editing: nil)
            }
        }
        .task { model.load() }
        .sheet(item: $form) { CategoryFormView(form: $0) }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TOTAL MONTHLY BUDGET")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

            Text(CurrencyFormatter.taka(model.totalBudget, showFraction: false))
                .font(.manrope, size: 30, weight: .extraBold)
                .foregroundStyle(CustomColor.darkGray.color)
                .contentTransition(.numericText())

            Text("\(model.budgetedCount) of \(model.categories.count) categories budgeted")
                .font(.manrope, size: 13, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.35))
            Text("No \(model.kind.singular) categories")
                .font(.manrope, size: 17, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
            Text("Create one to organise your \(model.kind.singular).")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .finoraCard()
    }
}

#Preview {
    NavigationStack {
        CategoriesView(model: CategoriesViewModel(repository: InMemoryCategoryRepository()))
    }
}
