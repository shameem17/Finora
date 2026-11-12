//
//  IncomeView.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//


import SwiftUI
import Charts
 
// MARK: - Period filter
 
enum IncomePeriod: String, PickerOption {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"
 
    var id: Self { self }
 
    /// Human-readable range shown under the card title.
    var subtitle: String {
        let cal = Calendar.current
        let now = Date()
        switch self {
        case .week:
            guard let interval = cal.dateInterval(of: .weekOfYear, for: now) else { return "This week" }
            let end = cal.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
            let style = Date.FormatStyle().day().month(.abbreviated)
            return "\(interval.start.formatted(style)) – \(end.formatted(style))"
        case .month:
            return now.formatted(.dateTime.month(.wide).year())
        case .year:
            return now.formatted(.dateTime.year())
        case .all:
            return "All time"
        }
    }
 
    /// DEMO ONLY: scales the sample data. Replace with real date-range filtering.
    var demoMultiplier: Double {
        switch self {
        case .week:  return 0.25
        case .month: return 1
        case .year:  return 11
        case .all:   return 18
        }
    }
}
 
// MARK: - Model
 
struct IncomeSource: Identifiable {
    var id: String { name }          // stable id so the chart animates between periods
    let name: String
    let amount: Double
    let color: Color
    let icon: String
}
 
private func takaString(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.locale = Locale(identifier: "en_IN")   // lakh/crore grouping
    f.maximumFractionDigits = 0
    return "৳" + (f.string(from: NSNumber(value: value)) ?? "0")
}
 
// MARK: - Screen
 
struct IncomeView: View {
    @State private var period: IncomePeriod = .month
 
    private let baseSources: [IncomeSource] = [
        .init(name: "Salary",    amount: 2000, color: Color(red: 0.12, green: 0.64, blue: 0.49), icon: "banknote"),
        .init(name: "Freelance", amount: 654,  color: Color(red: 0.18, green: 0.50, blue: 0.95), icon: "laptopcomputer"),
        .init(name: "Business",  amount: 500,  color: Color(red: 1.00, green: 0.36, blue: 0.13), icon: "storefront"),
        .init(name: "Gifts",     amount: 64,   color: Color(red: 0.62, green: 0.36, blue: 0.90), icon: "gift")
    ]
 
    private var sources: [IncomeSource] {
        baseSources
            .map { IncomeSource(name: $0.name,
                                amount: ($0.amount * period.demoMultiplier).rounded(),
                                color: $0.color,
                                icon: $0.icon) }
            .sorted { $0.amount > $1.amount }
    }
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()
 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PillPicker(selection: $period)
                        IncomeSummaryCard(period: period, sources: sources)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Income")
            .toolbar(content: {
                Button {
                    // add new income
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Add New")
                    }
                    .font(.manrope, size: 20, weight: .extraBold)
                                        
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            })
            .safeAreaInset(edge: .bottom) {
                Button {
                    // add new income
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Add New")
                    }
                    .font(.manrope, size: 20, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(CustomColor.warmCoral.color)
                    .clipShape(Capsule())
                    .shadow(color: CustomColor.warmCoral.color.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
}
 
// MARK: - Filter pills
 
struct PillPicker<Option: PickerOption>: View {
    @Binding var selection: Option
    @Namespace private var pill
 
    var body: some View {
        HStack(spacing: 4) {
                    ForEach(Array(Option.allCases)) { option in
                        let isSelected = selection == option

                        Text(option.title)
                            .font(.manrope, size: 14, weight: .bold)
                            .foregroundStyle(isSelected ? Color.white : CustomColor.darkGray.color.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(CustomColor.darkGray.color)
                                        .matchedGeometryEffect(id: "pill", in: pill)
                                }
                            }
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selection = option
                                }
                            }
                    }
                }
                .padding(4)
                .background(Capsule().fill(Color.white.opacity(0.75)))
                .overlay(Capsule().strokeBorder(Color.black.opacity(0.04), lineWidth: 1))
    }
}
 
// MARK: - Summary card
 
struct IncomeSummaryCard: View {
    let period: IncomePeriod
    let sources: [IncomeSource]
 
    private var total: Double { sources.reduce(0) { $0 + $1.amount } }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
 
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("Total Income")
                    .font(.manrope, size: 18, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color)
 
                Spacer()
 
                Text(period.subtitle)
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(CustomColor.darkGray.color.opacity(0.06), in: Capsule())
                    .contentTransition(.opacity)
            }
 
            // Donut
            Chart(sources) { s in
                SectorMark(
                    angle: .value("Amount", s.amount),
                    innerRadius: .ratio(0.74),
                    angularInset: 3
                )
                .cornerRadius(6)
                .foregroundStyle(s.color)
            }
            .frame(height: 230)
            .overlay {
                VStack(spacing: 4) {
                    Text("Earned")
                        .font(.manrope, size: 13, weight: .medium)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                        .tracking(1)
                        .textCase(.uppercase)
 
                    Text(takaString(total))
                        .font(.manrope, size: 32, weight: .extraBold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 50)
            }
            .animation(.smooth, value: period)
 
            Divider()
 
            // Sources
            VStack(spacing: 20) {
                ForEach(sources) { s in
                    IncomeSourceRow(source: s, fraction: total > 0 ? s.amount / total : 0)
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
}
 
// MARK: - Row
 
struct IncomeSourceRow: View {
    let source: IncomeSource
    let fraction: Double
 
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: source.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(source.color)
                .frame(width: 44, height: 44)
                .background(source.color.opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
 
            VStack(spacing: 8) {
                HStack {
                    Text(source.name)
                        .font(.manrope, size: 16, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                    Spacer()
                    Text(takaString(source.amount))
                        .font(.manrope, size: 16, weight: .extraBold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .contentTransition(.numericText())
                }
 
                HStack(spacing: 10) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(source.color.opacity(0.15))
                            Capsule()
                                .fill(source.color)
                                .frame(width: max(geo.size.width * fraction, 6))
                        }
                    }
                    .frame(height: 6)
 
                    Text("\(Int((fraction * 100).rounded()))%")
                        .font(.manrope, size: 12, weight: .semiBold)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                        .frame(width: 34, alignment: .trailing)
                }
            }
        }
        .animation(.smooth, value: fraction)
    }
}
 
#Preview {
    IncomeView()
}
