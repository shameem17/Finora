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
                                         ? CustomColor.customWhite.color
                                         : CustomColor.darkGray.color.opacity(0.55))
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
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(CustomColor.customWhite.color.opacity(0.75)))
        .overlay(Capsule().strokeBorder(Color.black.opacity(0.04), lineWidth: 1))
    }
}
