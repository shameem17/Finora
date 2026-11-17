//
//  SavingsView.swift
//  Finora
//
//  Screens/Savings/View
//
//  Hosted by SavingsCoordinator inside its UINavigationController, so there is
//  no NavigationStack here: the title bridges to the UIKit bar.
//

import SwiftUI

struct SavingsView<ViewModel: SavingsViewModelProtocol>: View {

    let model: ViewModel
    @State private var form: SavingsFormViewModel?
    @State private var entryForm: SavingsEntryFormViewModel?
    @State private var log: SavingsLogViewModel?

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if model.items.isEmpty {
                        emptyState
                    } else {
                        SavingsSummaryCard(summary: model.summary)

                        if !model.summary.breakdown.isEmpty {
                            SavingsBreakdownCard(rows: model.summary.breakdown)
                        }

                        list
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Savings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { log = model.makeLogViewModel() } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("Savings log")
            }
        }
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: "Add Savings Account", tint: .incoming) {
                form = model.makeFormViewModel()
            }
        }
        .task { model.load() }
        .sheet(item: $form) { SavingsFormView(form: $0) }
        .sheet(item: $entryForm) { SavingsEntryFormView(form: $0) }
        .sheet(item: $log) { SavingsLogView(model: $0, isSheet: true) }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Savings accounts")

            ForEach(model.items) { item in
                SavingsCard(item: item,
                            onAdd: { entryForm = model.makeEntryFormViewModel(for: item.id, kind: .deposit) },
                            onWithdraw: { entryForm = model.makeEntryFormViewModel(for: item.id, kind: .withdrawal) })
                    .onTapGesture { model.showDetail(of: item.id) }
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    private var emptyState: some View {
        EmptyStateCard(icon: "lock.shield",
                       title: "No savings yet",
                       message: "Create a savings account tagged to your bank or wallet, set a target and watch it grow.")
    }
}

#Preview {
    NavigationStack {
        SavingsView(model: SavingsViewModel(dependencies: .preview()))
    }
}
