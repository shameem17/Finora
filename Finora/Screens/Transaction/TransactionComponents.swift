//
//  TransactionComponents.swift
//  Finora
//
//  Screens/Transaction/View
//

import SwiftUI

// MARK: - Shared card style (matches Income / Home cards)

extension View {
    func finoraCard(cornerRadius: CGFloat = 28) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CustomColor.customWhite.color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Account badge

struct AccountBadge: View {
    let type: AccountType
    let tint: String
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: type.icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color(hex: tint),
                        in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

// MARK: - Summary card

struct TransferSummaryCard: View {
    let period: TransferPeriod
    let summary: TransferSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .firstTextBaseline) {
                Text("Total Transferred")
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

            Text(CurrencyFormatter.taka(summary.totalAmount))
                .font(.manrope, size: 40, weight: .extraBold)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())

            Divider()

            HStack(spacing: 12) {
                StatTile(title: "Charges paid",
                         value: CurrencyFormatter.taka(summary.totalCharges, showFraction: true),
                         icon: "percent",
                         tint: CustomColor.warmCoral.color)

                StatTile(title: "Transfers",
                         value: "\(summary.count)",
                         icon: "arrow.left.arrow.right",
                         tint: CustomColor.electricPurple.color)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .animation(.smooth, value: summary)
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
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
                Text(value)
                    .font(.manrope, size: 15, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fillSubtle,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - History row

struct TransferRow: View {
    let transfer: Transfer

    var body: some View {
        HStack(spacing: 14) {
            // Overlapping badges: source behind, destination in front.
            ZStack(alignment: .topLeading) {
                AccountBadge(type: transfer.from.type, tint: transfer.from.tint, size: 30)
                AccountBadge(type: transfer.to.type, tint: transfer.to.tint, size: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(CustomColor.customWhite.color, lineWidth: 2)
                    )
                    .offset(x: 14, y: 14)
            }
            .frame(width: 46, height: 46, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(transfer.from.name) → \(transfer.to.name)")
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(transfer.reason.isEmpty ? "Balance transfer" : transfer.reason)
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(CurrencyFormatter.taka(transfer.amount, showFraction: true))
                    .font(.manrope, size: 15, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                if transfer.charge > 0 {
                    Text("+\(CurrencyFormatter.taka(transfer.charge, showFraction: true)) fee")
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(CustomColor.warmCoral.color)
                }
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Empty state

struct EmptyTransfersView: View {
    let period: TransferPeriod

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right.circle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.textTertiary)

            Text("No transfers yet")
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Text(period == .all
                 ? "Move money between your accounts and it will show up here."
                 : "Nothing recorded for this period.")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}
