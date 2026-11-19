//
//  FinanceOverviewCard.swift
//  Finora
//
//  Screens/Home/View
//
//  Net-worth summary: a teal hero with the headline figure and a 2x2 grid of the
//  numbers behind it.
//

import SwiftUI

struct FinanceOverviewCard: View {

    let overview: FinanceOverview
    var hidesBalances = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                tile(icon: "building.columns.fill",
                     title: "Accounts",
                     value: overview.accountsTotal,
                     caption: count(overview.accountCount, "account"))
                tile(icon: "arrow.down.left",
                     title: "To collect",
                     value: overview.toCollect,
                     caption: "Lent, remaining")
                tile(icon: "arrow.up.right",
                     title: "To repay",
                     value: overview.toRepay,
                     caption: "Borrowed, remaining")
                tile(icon: "chart.line.uptrend.xyaxis",
                     title: "Savings",
                     value: overview.savings,
                     caption: count(overview.savingsCount, "goal"))
            }

            Divider().overlay(Color.onHeroSecondary.opacity(0.25))

            HStack {
                Label("This month", systemImage: "calendar")
                    .font(.manrope, size: 13, weight: .semiBold)
                    .foregroundStyle(Color.onHeroSecondary)
                Spacer()
                Text(signed(overview.monthBalance))
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.onHero)
                    .contentTransition(.numericText())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .heroCard()
        .animation(.smooth, value: overview)
        .accessibilityElement(children: .contain)
    }

    // MARK: Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Net worth")
                .font(.manrope, size: 12, weight: .semiBold)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color.onHeroSecondary)

            Text(format(overview.netWorth))
                .font(.manrope, size: 34, weight: .extraBold)
                .foregroundStyle(Color.onHero)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())

            Text("Accounts + to collect − to repay")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(Color.onHeroSecondary)
        }
    }

    private func tile(icon: String, title: String, value: Double, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.onAccent)
                    .frame(width: 24, height: 24)
                    .background(Color.accent, in: Circle())
                Text(title)
                    .font(.manrope, size: 13, weight: .semiBold)
                    .foregroundStyle(Color.onHeroSecondary)
            }

            Text(format(value))
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.onHero)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())

            Text(caption)
                .font(.manrope, size: 11, weight: .medium)
                .foregroundStyle(Color.onHeroSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.onHero.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: Formatting

    private func format(_ value: Double) -> String {
        hidesBalances ? CurrencyFormatter.hidden : CurrencyFormatter.taka(value)
    }

    private func signed(_ value: Double) -> String {
        guard !hidesBalances else { return CurrencyFormatter.hidden }
        let sign = value > 0 ? "+" : (value < 0 ? "−" : "")
        return sign + CurrencyFormatter.taka(abs(value))
    }

    private func count(_ n: Int, _ noun: String) -> String {
        n == 1 ? "1 \(noun)" : "\(n) \(noun)s"
    }
}

#Preview {
    FinanceOverviewCard(overview: FinanceOverview(accountsTotal: 183_560,
                                                  accountCount: 4,
                                                  toCollect: 12_000,
                                                  toRepay: 4_500,
                                                  savings: 60_000,
                                                  savingsCount: 2,
                                                  monthBalance: 43_750))
        .padding()
        .background(Color.screenBackground)
}
