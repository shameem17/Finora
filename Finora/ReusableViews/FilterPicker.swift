//
//  FilterPicker.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import SwiftUI

// MARK: - Reusable: filter pills

struct PillPicker<Option: PickerOption>: View {
    @Binding var selection: Option
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(Option.allCases)) { option in
                let isSelected = selection == option

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = option
                    }
                } label: {
                    Text(option.title)
                        .font(.manrope, size: 14, weight: .bold)
                        .foregroundStyle(isSelected
                                         ? Color.onAccent
                                         : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.accent)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.cardSurface))
        .overlay(Capsule().strokeBorder(Color.brandSecondary.opacity(0.06), lineWidth: 1))
    }
}
