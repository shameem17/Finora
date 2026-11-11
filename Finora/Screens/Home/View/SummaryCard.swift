//
//  SummaryCard.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//

import SwiftUI

struct SummaryCard: View {
    let type: SummaryType
    var amount: String = "$400"   // pass the real value in

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

            // Amount
            Text(amount)
                .font(.manrope, size: 26, weight: .extraBold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))

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
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
