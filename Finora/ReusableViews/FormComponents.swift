//
//  FormComponents.swift
//  Finora
//
//  Small building blocks shared by every form / list screen.
//

import SwiftUI

// MARK: - Form row

/// Icon + title on the left, any control on the right.
struct FormFieldRow<Content: View>: View {
    let icon: String
    let title: String
    var alignTop = false
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: alignTop ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                .frame(width: 32, height: 32)
                .background(CustomColor.darkGray.color.opacity(0.06),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.manrope, size: 14, weight: .semiBold)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)
            content
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Key / value line

struct ValueRow: View {
    let title: String
    let value: String
    var emphasized = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.manrope, size: 14, weight: emphasized ? .bold : .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(emphasized ? 1 : 0.6))
            Spacer(minLength: 8)
            Text(value)
                .font(.manrope, size: 14, weight: emphasized ? .extraBold : .semiBold)
                .foregroundStyle(CustomColor.darkGray.color)
                .multilineTextAlignment(.trailing)
                .contentTransition(.numericText())
        }
    }
}

// MARK: - Search

struct SearchField: View {
    @Binding var text: String
    var prompt = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.45))

            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.35))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .font(.manrope, size: 15, weight: .semiBold)
        .foregroundStyle(CustomColor.darkGray.color)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Capsule().fill(CustomColor.customWhite.color.opacity(0.75)))
        .overlay(Capsule().strokeBorder(Color.black.opacity(0.04), lineWidth: 1))
    }
}

// MARK: - Error banner

struct FormErrorBanner: View {
    let message: String?

    var body: some View {
        if let message {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.manrope, size: 13, weight: .semiBold)
                .foregroundStyle(CustomColor.dangerRed.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(CustomColor.dangerRed.color.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.opacity)
        }
    }
}

// MARK: - Primary button

/// Full-width capsule used for "Save" at the bottom of forms.
struct FormPrimaryButton: View {
    let title: String
    var tint: CustomColor = .warmCoral
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.manrope, size: 20, weight: .extraBold)
                .foregroundStyle(CustomColor.darkGray.color)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(tint.color)
                .clipShape(Capsule())
                .shadow(color: tint.color.opacity(0.4), radius: 12, y: 6)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
