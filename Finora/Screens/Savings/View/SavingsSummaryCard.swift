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
                SectionLabel("Total savings")

                Text(CurrencyFormatter.taka(summary.totalSavings, showFraction: true))
                    .font(.manrope, size: 34, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }

            if let progress = summary.progress {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressBar(fraction: progress, color: Color.brandSecondary)
                    Text("\(Int((progress * 100).rounded()))% of \(CurrencyFormatter.taka(summary.totalTarget)) target")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Divider()

            HStack(alignment: .top, spacing: 0) {
                StatColumn(title: "Deposited", value: CurrencyFormatter.taka(summary.totalDeposited))
                StatColumn(title: "Withdrawn", value: CurrencyFormatter.taka(summary.totalWithdrawn))
                StatColumn(title: "Goals reached", value: "\(summary.goalsReached)/\(summary.count)")
            }
        }
        .sectionCard()
    }
}

/// Account-wise split of all savings.
struct SavingsBreakdownCard: View {
    let rows: [SavingsBreakdownRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Breakdown by account")

            ForEach(rows) { row in
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        AccountBadge(type: row.type, tint: row.tint, size: 34)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(row.name)
                                .font(.manrope, size: 14, weight: .bold)
                                .foregroundStyle(Color.textPrimary)
                            Text(row.count == 1 ? "1 savings account" : "\(row.count) savings accounts")
                                .font(.manrope, size: 11, weight: .medium)
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer(minLength: 8)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text(CurrencyFormatter.taka(row.amount, showFraction: true))
                                .font(.manrope, size: 14, weight: .extraBold)
                                .foregroundStyle(Color.textPrimary)
                            Text("\(Int((row.share * 100).rounded()))%")
                                .font(.manrope, size: 11, weight: .semiBold)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    ProgressBar(fraction: row.share, color: Color(hex: row.tint))
                }
                .accessibilityElement(children: .combine)
            }
        }
        .sectionCard()
    }
}
