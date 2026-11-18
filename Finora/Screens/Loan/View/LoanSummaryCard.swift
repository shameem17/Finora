//
//  LoanSummaryCard.swift
//  Finora
//
//  Screens/Loan/View
//

import SwiftUI

struct LoanSummaryCard: View {
    let period: ReportPeriod
    let summary: LoanSummary

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            netPosition

            HStack(spacing: 12) {
                BalanceTile(title: "To receive",
                            value: summary.toReceive,
                            caption: countCaption(summary.activeLentCount),
                            icon: "arrow.down.left",
                            tint: Color.positive)

                BalanceTile(title: "To pay",
                            value: summary.toPay,
                            caption: countCaption(summary.activeBorrowedCount),
                            icon: "arrow.up.right",
                            tint: Color.negative)
            }

            Divider()

            sectionLabel("Activity \(period.phrase)")
            LazyVGrid(columns: columns, spacing: 12) {
                StatTile(title: "Lent out",
                         value: CurrencyFormatter.taka(summary.lentInPeriod),
                         icon: "arrow.up.right",
                         tint: Color.brandAccent)

                StatTile(title: "Borrowed",
                         value: CurrencyFormatter.taka(summary.borrowedInPeriod),
                         icon: "arrow.down.left",
                         tint: Color.brandAccent)

                StatTile(title: "Received back",
                         value: CurrencyFormatter.taka(summary.receivedInPeriod),
                         icon: "checkmark.circle",
                         tint: Color.positive)

                StatTile(title: "Paid back",
                         value: CurrencyFormatter.taka(summary.repaidInPeriod),
                         icon: "checkmark.circle",
                         tint: Color.brandAccent)
            }

            sectionLabel(period == .all ? "Scheduled in total" : "Due \(period.phrase)")
            HStack(alignment: .top, spacing: 12) {
                StatTile(title: "You need to pay",
                         value: CurrencyFormatter.taka(summary.dueToPay),
                         icon: "calendar.badge.clock",
                         tint: Color.negative,
                         caption: overdueCaption(summary.overdueToPay))

                StatTile(title: "You'll receive",
                         value: CurrencyFormatter.taka(summary.dueToReceive),
                         icon: "calendar.badge.checkmark",
                         tint: Color.positive,
                         caption: overdueCaption(summary.overdueToReceive))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .animation(.smooth, value: summary)
    }

    // MARK: Pieces

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Loan Overview")
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(period.subtitle)
                .font(.manrope, size: 13, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.fillSubtle, in: Capsule())
                .contentTransition(.opacity)
        }
    }

    private var netPosition: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NET POSITION")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(Color.textSecondary)

            Text(netText)
                .font(.manrope, size: 40, weight: .extraBold)
                .foregroundStyle(netColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())

            Text(netCaption)
                .font(.manrope, size: 13, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.manrope, size: 12, weight: .semiBold)
            .tracking(1)
            .foregroundStyle(Color.textSecondary)
    }

    // MARK: Copy

    private var isSquare: Bool { abs(summary.net) < Loan.tolerance }

    private var netText: String {
        let amount = CurrencyFormatter.taka(abs(summary.net))
        if isSquare { return amount }
        return (summary.net > 0 ? "+" : "−") + amount
    }

    private var netColor: Color {
        if isSquare { return Color.textPrimary }
        return summary.net > 0 ? Color.positive : Color.negative
    }

    private var netCaption: String {
        if isSquare { return "You're all square." }
        return summary.net > 0 ? "You're owed more than you owe." : "You owe more than you're owed."
    }

    private func countCaption(_ count: Int) -> String {
        switch count {
        case 0:  return "Nothing open"
        case 1:  return "1 open entry"
        default: return "\(count) open entries"
        }
    }

    private func overdueCaption(_ amount: Double) -> String? {
        amount >= Loan.tolerance ? "\(CurrencyFormatter.taka(amount)) overdue" : nil
    }
}

// MARK: - Tiles

private struct BalanceTile: View {
    let title: String
    let value: Double
    let caption: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)
                    .background(tint.opacity(0.14),
                                in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text(title)
                    .font(.manrope, size: 13, weight: .semiBold)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(CurrencyFormatter.taka(value))
                    .font(.manrope, size: 22, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())

                Text(caption)
                    .font(.manrope, size: 11, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color
    var caption: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(value)
                    .font(.manrope, size: 15, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())

                if let caption {
                    Text(caption)
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(Color.negative)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fillSubtle,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        ScrollView {
            LoanSummaryCard(
                period: .month,
                summary: LoanSummary(toReceive: 15_000, toPay: 66_000 - 11_000,
                                     activeLentCount: 3, activeBorrowedCount: 2,
                                     lentInPeriod: 5_000, borrowedInPeriod: 3_000,
                                     receivedInPeriod: 5_000, repaidInPeriod: 11_000,
                                     dueToReceive: 15_000, dueToPay: 14_000,
                                     overdueToReceive: 15_000, overdueToPay: 0)
            )
            .padding()
        }
    }
}
