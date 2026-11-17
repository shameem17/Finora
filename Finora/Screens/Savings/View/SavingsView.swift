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

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

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
                Button { model.showLog() } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("Savings log")
            }
        }
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: "Add Savings Account", tint: .vividTeal) {
                form = model.makeFormViewModel()
            }
        }
        .task { model.load() }
        .sheet(item: $form) { SavingsFormView(form: $0) }
        .sheet(item: $entryForm) { SavingsEntryFormView(form: $0) }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAVINGS ACCOUNTS")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

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
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.35))

            Text("No savings yet")
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)

            Text("Create a savings account tagged to your bank or wallet, set a target and watch it grow.")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}

#Preview {
    NavigationStack {
        SavingsView(model: SavingsViewModel(dependencies: .preview()))
    }
}
