//
//  CategoryComponents.swift
//  Finora
//
//  Screens/Categories/View
//

import SwiftUI

struct CategoryIconBadge: View {
    let icon: String
    let tint: String
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(Color(hex: tint))
            .frame(width: size, height: size)
            .background(Color(hex: tint).opacity(0.15), in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct CategoryRow: View {
    let category: TransactionCategory

    var body: some View {
        HStack(spacing: 14) {
            CategoryIconBadge(icon: category.icon, tint: category.tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(category.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                if category.kind == .expense {
                    Text(category.monthlyBudget.map { "Budget \(CurrencyFormatter.taka($0, showFraction: false)) / month" } ?? "No budget set")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(14)
        .contentShape(Rectangle())
        .finoraCard()
        .accessibilityElement(children: .combine)
    }
}
