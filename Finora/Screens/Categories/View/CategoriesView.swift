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
            Color.screenBackground.ignoresSafeArea()

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
            SectionLabel("Total monthly budget")

            Text(CurrencyFormatter.taka(model.totalBudget))
                .font(.manrope, size: 30, weight: .extraBold)
                .foregroundStyle(Color.textPrimary)
                .contentTransition(.numericText())

            Text("\(model.budgetedCount) of \(model.categories.count) categories budgeted")
                .font(.manrope, size: 13, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
        .sectionCard()
    }

    private var emptyState: some View {
        EmptyStateCard(icon: "square.grid.2x2",
                       title: "No \(model.kind.singular) categories",
                       message: "Create one to organise your \(model.kind.singular).")
    }
}

#Preview {
    NavigationStack {
        CategoriesView(model: CategoriesViewModel(repository: InMemoryCategoryRepository()))
    }
}
