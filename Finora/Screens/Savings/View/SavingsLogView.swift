//
//  SavingsLogView.swift
//  Finora
//
//  Screens/Savings/View
//
//  Read-only log of every amount added to or withdrawn from savings.
//

import SwiftUI

struct SavingsLogView<ViewModel: SavingsLogViewModelProtocol>: View {

    @Bindable var model: ViewModel
    /// Presented modally (wraps itself in a NavigationStack and adds a Done button).
    var isSheet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if isSheet {
            NavigationStack {
                content
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { dismiss() }
                                .font(.manrope, size: 16, weight: .semiBold)
                        }
                    }
            }
            .presentationDragIndicator(.visible)
        } else {
            content
        }
    }

    private var content: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16, pinnedViews: []) {
                    PillPicker(selection: $model.filter)
                    totalsCard

                    if model.sections.isEmpty {
                        emptyState
                    } else {
                        ForEach(model.sections) { section in
                            sectionCard(section)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .animation(.smooth, value: model.filter)
            }
        }
        .navigationTitle(model.scopeTitle ?? "Savings Log")
        .navigationBarTitleDisplayMode(.inline)
        .task { model.load() }
    }

    private var totalsCard: some View {
        HStack(alignment: .top) {
            StatColumn(title: "Added", value: CurrencyFormatter.taka(model.totalAdded, showFraction: true), color: .positive)
            StatColumn(title: "Withdrawn", value: CurrencyFormatter.taka(model.totalWithdrawn, showFraction: true), color: .negative)
            StatColumn(title: "Net", value: CurrencyFormatter.taka(model.totalAdded - model.totalWithdrawn, showFraction: true))
        }
        .sectionCard()
    }

    private func sectionCard(_ section: SavingsLogSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionLabel(section.id.formatted(.dateTime.month(.wide).year()))
                Spacer()
                Text("Net \(section.net < 0 ? "−" : "")\(CurrencyFormatter.taka(abs(section.net)))")
                    .font(.manrope, size: 12, weight: .bold)
                    .foregroundStyle(Color.textSecondary)
            }

            ForEach(section.entries) { log in
                SavingsEntryRow(entry: log.entry,
                                savingsName: model.scopeTitle == nil ? log.savingsName : nil)
                if log.id != section.entries.last?.id { Divider() }
            }
        }
        .sectionCard()
    }

    private var emptyState: some View {
        EmptyStateCard(icon: "clock.arrow.circlepath",
                       title: model.isEmpty ? "No activity yet" : "Nothing to show",
                       message: model.isEmpty ? "Every amount you add or withdraw will be listed here."
                                              : "Try a different filter.")
    }
}

#Preview {
    NavigationStack {
        SavingsLogView(model: SavingsLogViewModel(dependencies: .preview()))
    }
}
