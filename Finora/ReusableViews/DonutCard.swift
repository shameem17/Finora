//
//  DonutCard.swift
//  Finora
//
//  Reusable donut + breakdown list. Used by Home, Income and Expense.
//

import SwiftUI
import Charts

// MARK: - Model

/// One slice of a donut (an income source, an expense category, ...).
struct BreakdownItem: Identifiable, Equatable {
    var id: String { name }          // stable id so the chart animates between updates
    let name: String
    let amount: Double
    let color: Color
    let icon: String
}

// MARK: - Currency

enum TakaFormatter {
    private static let locale = Locale(identifier: "en_IN")   // lakh/crore grouping

    static func string(_ value: Double, fractionDigits: Int = 0) -> String {
        CurrencyFormatter.symbol + value.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(fractionDigits))
        )
    }
}

// MARK: - Donut card

struct DonutCard: View {
    var title: String? = nil
    var subtitle: String? = nil
    let centerCaption: String
    let items: [BreakdownItem]

    private var total: Double { items.reduce(0) { $0 + $1.amount } }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let title {
                header(title: title)
            }

            chart

            Divider()

            VStack(spacing: 20) {
                ForEach(items) { item in
                    BreakdownRow(item: item,
                                 fraction: total > 0 ? item.amount / total : 0)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.cardSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 6)
    }

    // MARK: Pieces

    private func header(title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            if let subtitle {
                Text(subtitle)
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.fillSubtle, in: Capsule())
                    .contentTransition(.opacity)
            }
        }
    }

    private var chart: some View {
        Chart(items) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.74),
                angularInset: 3
            )
            .cornerRadius(6)
            .foregroundStyle(item.color)
        }
        .frame(height: 230)
        .overlay {
            VStack(spacing: 4) {
                Text(centerCaption)
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(TakaFormatter.string(total))
                    .font(.manrope, size: 32, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 50)
        }
        .animation(.smooth, value: items)
    }
}
