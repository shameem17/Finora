//
//  AddButton.swift
//  Finora
//
//  Created by Shameem on 11/12/26.
//

import SwiftUI

// MARK: - Reusable: bottom action button

struct AddActionButton: View {
    let title: String
    var tint: CustomColor = .warmCoral
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                Text(title)
            }
            .font(.manrope, size: 20, weight: .extraBold)
            .foregroundStyle(CustomColor.darkGray.color)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(tint.color)
            .clipShape(Capsule())
            .shadow(color: tint.color.opacity(0.4), radius: 12, y: 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
