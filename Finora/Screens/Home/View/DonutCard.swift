//
//  temp.swift
//  Finora
//
//  Created by Shameem on 11/10/26.
//

import SwiftUI
import Charts

struct IncomeItem: Identifiable {
    let id = UUID()
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

struct DonutCard: View {
    let items: [IncomeItem] = [
        .init(name: "Salary",    amount: 2000, color: Color(red: 0.12, green: 0.64, blue: 0.49), icon: "banknote"),
        .init(name: "Freelance", amount: 500,  color: Color(red: 0.18, green: 0.50, blue: 0.95), icon: "laptopcomputer"),
        .init(name: "Business",  amount: 64,   color: Color(red: 1.0,  green: 0.36, blue: 0.13), icon: "storefront"),
        .init(name: "Business2",  amount: 654,   color: Color(red: 1.0,  green: 0.36, blue: 0.13), icon: "storefront"),
    ]

    var total: Double { items.reduce(0) { $0 + $1.amount } }

    var body: some View {
        VStack(spacing: 28) {
            Chart(items) { s in
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
            VStack(spacing: 20) {
                ForEach(items) { item in
                    LegendRow(item: item, percent: item.amount / total)
                }
            }
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 28))
        .padding()
    }
}

struct LegendRow: View {
    let item: IncomeItem
    let percent: Double

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(item.color, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.headline)
                Text("\(Int((percent * 100).rounded()))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("৳\(Int(item.amount))").font(.headline)
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()
        DonutCard()
    }
}
