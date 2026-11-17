//
//  SavingsSummaryCard.swift
//  Finora
//
//  Screens/Savings/View
//

import SwiftUI

struct SavingsSummaryCard: View {
    let summary: SavingsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL SAVINGS")
                    .font(.manrope, size: 12, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

                Text(CurrencyFormatter.taka(summary.totalSavings, showFraction: true))
                    .font(.manrope, size: 34, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }

            if let progress = summary.progress {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressBar(fraction: progress, color: CustomColor.vividTeal.color)
                    Text("\(Int((progress * 100).rounded()))% of \(CurrencyFormatter.taka(summary.totalTarget)) target")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                }
            }

            Divider()

            HStack(alignment: .top, spacing: 0) {
                stat("Deposited", CurrencyFormatter.taka(summary.totalDeposited))
                stat("Withdrawn", CurrencyFormatter.taka(summary.totalWithdrawn))
                stat("Goals reached", "\(summary.goalsReached)/\(summary.count)")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.manrope, size: 11, weight: .semiBold)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
            Text(value)
                .font(.manrope, size: 15, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Account-wise split of all savings.
struct SavingsBreakdownCard: View {
    let rows: [SavingsBreakdownRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BREAKDOWN BY ACCOUNT")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

            ForEach(rows) { row in
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        AccountBadge(type: row.type, tint: row.tint, size: 34)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(row.name)
                                .font(.manrope, size: 14, weight: .bold)
                                .foregroundStyle(CustomColor.darkGray.color)
                            Text(row.count == 1 ? "1 savings account" : "\(row.count) savings accounts")
                                .font(.manrope, size: 11, weight: .medium)
                                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
                        }

                        Spacer(minLength: 8)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text(CurrencyFormatter.taka(row.amount, showFraction: true))
                                .font(.manrope, size: 14, weight: .extraBold)
                                .foregroundStyle(CustomColor.darkGray.color)
                            Text("\(Int((row.share * 100).rounded()))%")
                                .font(.manrope, size: 11, weight: .semiBold)
                                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
                        }
                    }
                    ProgressBar(fraction: row.share, color: Color(hex: row.tint))
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }
}
