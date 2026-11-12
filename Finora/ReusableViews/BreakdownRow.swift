//
//  BreakdownRow.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import SwiftUI

// MARK: - Row

struct BreakdownRow: View {
    let item: BreakdownItem
    let fraction: Double

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(item.color)
                .frame(width: 44, height: 44)
                .background(item.color.opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.manrope, size: 16, weight: .bold)
                    Spacer()
                    Text(TakaFormatter.string(item.amount))
                        .font(.manrope, size: 16, weight: .extraBold)
                        .contentTransition(.numericText())
                }
                .foregroundStyle(CustomColor.darkGray.color)

                HStack(spacing: 10) {
                    ProgressBar(fraction: fraction, color: item.color)

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
