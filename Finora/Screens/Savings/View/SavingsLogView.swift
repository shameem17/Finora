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

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

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
            stat("Added", model.totalAdded, CustomColor.successGreen.color)
            stat("Withdrawn", model.totalWithdrawn, CustomColor.dangerRed.color)
            stat("Net", model.totalAdded - model.totalWithdrawn, CustomColor.darkGray.color)
        }
        .padding(20)
        .finoraCard()
    }

    private func stat(_ title: String, _ value: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.manrope, size: 11, weight: .semiBold)
                .tracking(0.8)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
            Text(CurrencyFormatter.taka(value, showFraction: true))
                .font(.manrope, size: 15, weight: .extraBold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionCard(_ section: SavingsLogSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.id.formatted(.dateTime.month(.wide).year()).uppercased())
                    .font(.manrope, size: 12, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                Spacer()
                Text("Net \(section.net < 0 ? "−" : "")\(CurrencyFormatter.taka(abs(section.net)))")
                    .font(.manrope, size: 12, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
            }

            ForEach(section.entries) { log in
                SavingsEntryRow(entry: log.entry,
                                savingsName: model.scopeTitle == nil ? log.savingsName : nil)
                if log.id != section.entries.last?.id { Divider() }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.35))
            Text(model.isEmpty ? "No activity yet" : "Nothing to show")
                .font(.manrope, size: 17, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
            Text(model.isEmpty ? "Every amount you add or withdraw will be listed here."
                               : "Try a different filter.")
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
        SavingsLogView(model: SavingsLogViewModel(dependencies: .preview()))
    }
}
