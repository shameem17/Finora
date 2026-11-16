//
//  ColorSwatchPicker.swift
//  Finora
//
//  Preset colours plus a system ColorPicker for anything custom.
//  Binds to a hex string (`#RRGGBB`) so it can be stored as-is.
//

import SwiftUI

struct ColorSwatchPicker: View {

    @Binding var hex: String
    var presets: [String] = ColorSwatchPicker.defaultPresets

    /// Mid / dark tones so white text and icons stay readable on top.
    static let defaultPresets = [
        "#007366", "#2E7D32", "#1A4DB3", "#6640D9", "#A259FF", "#E31266",
        "#F2661A", "#B45309", "#1F2433", "#455A64", "#8E24AA"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(presets, id: \.self) { preset in
                swatch(preset)
            }
            customPicker
        }
    }

    private func swatch(_ preset: String) -> some View {
        let isSelected = preset.caseInsensitiveCompare(hex) == .orderedSame

        return Button {
            hex = preset
        } label: {
            Circle()
                .fill(Color(hex: preset))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                }
                .overlay(Circle().strokeBorder(Color.black.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Colour \(preset)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var customPicker: some View {
        ColorPicker("Custom colour",
                    selection: Binding(get: { Color(hex: hex) },
                                       set: { hex = $0.hexString }),
                    supportsOpacity: false)
            .labelsHidden()
            .frame(maxWidth: .infinity)
    }
}
