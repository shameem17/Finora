//
//  SummaryCard.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//

import SwiftUI
 
// MARK: - Overview tile (Income / Expense / Balance)
 
struct SummaryCard: View {
    let type: SummaryType
    var amount: String = "—"
 
    private var color: Color { type.brandColor.color }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
 
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(color.opacity(0.14))
                    Circle()
                        .fill(color)
                        .frame(width: 9, height: 9)
                }
                .frame(width: 28, height: 28)
 
                Text(type.name)
                    .font(.manrope, size: 14, weight: .medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
 
            Text(amount)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.cardSurface)
 
                // Faint brand tint fading from the top-left corner
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.10), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(color.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.brandSecondary.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}
 
// MARK: - Insights card
 
struct InsightsCard: View {
    let insights: MonthlyInsights
 
    private var ink: Color { Color.textPrimary }
 
    private var ringColor: Color {
        switch insights.savingsRate {
        case 0.2...:  return Color.brandSecondary
        case 0.1...:  return Color.brandSecondary.opacity(0.75)
        default:      return Color.brandSecondary.opacity(0.5)
        }
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 18) {
                SavingsRing(progress: insights.savingsRate, color: ringColor)
                    .frame(width: 96, height: 96)
 
                VStack(alignment: .leading, spacing: 6) {
                    Text("Savings rate")
                        .font(.manrope, size: 12, weight: .semiBold)
                        .foregroundStyle(ink.opacity(0.55))
                        .textCase(.uppercase)
                        .tracking(1)
 
                    Text("You've kept \(Int((insights.savingsRate * 100).rounded()))% of your income")
                        .font(.manrope, size: 16, weight: .bold)
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
 
                    paceLabel
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
 
            Divider()
 
            HStack(spacing: 10) {
                InsightStat(icon: "calendar",
                            title: "Daily avg",
                            value: TakaFormatter.string(insights.dailyAverage),
                            tint: Color.brandSecondary)
 
                InsightStat(icon: insights.topExpense.icon,
                            title: "Top spend",
                            value: insights.topExpense.name,
                            caption: TakaFormatter.string(insights.topExpense.amount),
                            tint: insights.topExpense.color)
 
                changeStat
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
                .strokeBorder(Color.brandSecondary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.brandSecondary.opacity(0.08), radius: 14, x: 0, y: 6)
    }
 
    // MARK: Pieces
 
    @ViewBuilder
    private var paceLabel: some View {
        switch insights.pace {
        case .onTrack(let surplus):
            Label("On track to save \(TakaFormatter.string(surplus))",
                  systemImage: "arrow.up.right.circle.fill")
                .foregroundStyle(Color.positive)
                .font(.manrope, size: 13, weight: .semiBold)
        case .overspending(let deficit):
            Label("Projected to overspend by \(TakaFormatter.string(deficit))",
                  systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.negative)
                .font(.manrope, size: 13, weight: .semiBold)
        }
    }
 
    @ViewBuilder
    private var changeStat: some View {
        if let change = insights.expenseChange {
            let isDown = change <= 0          // spending less is good
            InsightStat(icon: isDown ? "arrow.down.right" : "arrow.up.right",
                        title: "vs last month",
                        value: "\(Int((abs(change) * 100).rounded()))%",
                        tint: isDown ? Color.positive
                                     : Color.negative)
        } else {
            InsightStat(icon: "minus",
                        title: "vs last month",
                        value: "—",
                        tint: Color.textSecondary)
        }
    }
}
 
// MARK: - Pieces
 
private struct SavingsRing: View {
    let progress: Double
    let color: Color
 
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 10)
 
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
 
            Text("\(Int((progress * 100).rounded()))%")
                .font(.manrope, size: 20, weight: .extraBold)
                .foregroundStyle(Color.textPrimary)
                .contentTransition(.numericText())
        }
        .animation(.smooth, value: progress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Savings rate")
        .accessibilityValue("\(Int((progress * 100).rounded())) percent")
    }
}
 
private struct InsightStat: View {
    let icon: String
    let title: String
    let value: String
    var caption: String? = nil
    let tint: Color
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
 
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manrope, size: 11, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
 
                Text(value)
                    .font(.manrope, size: 15, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
 
                // Always reserve the line so all three tiles share one height.
                Text(caption ?? " ")
                    .font(.manrope, size: 11, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.07),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
 
#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        InsightsCard(insights: .sample)
            .padding()
    }
}
