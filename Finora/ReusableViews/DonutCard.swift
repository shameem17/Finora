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
        "৳" + value.formatted(
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
                .fill(CustomColor.customWhite.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    // MARK: Pieces

    private func header(title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)

            Spacer()

            if let subtitle {
                Text(subtitle)
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(CustomColor.darkGray.color.opacity(0.06), in: Capsule())
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
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    .tracking(1)
                    .textCase(.uppercase)

                Text(TakaFormatter.string(total))
                    .font(.manrope, size: 32, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 50)
        }
        .animation(.smooth, value: items)
    }
}
// MARK: - Temporary sample data (remove once the repository exists)

extension BreakdownItem {
    static let sampleIncome: [BreakdownItem] = [
        .init(name: "Salary",    amount: 2000, color: CustomColor.vividTeal.color,      icon: "banknote"),
        .init(name: "Freelance", amount: 654,  color: CustomColor.royalAzure.color,    icon: "laptopcomputer"),
        .init(name: "Business",  amount: 500,  color: CustomColor.warmCoral.color,     icon: "storefront"),
        .init(name: "Gifts",     amount: 64,   color: CustomColor.electricPurple.color, icon: "gift")
    ]
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        DonutCard(title: "Total Income",
                  subtitle: "November 2026",
                  centerCaption: "Earned",
                  items: BreakdownItem.sampleIncome)
            .padding()
    }
}
