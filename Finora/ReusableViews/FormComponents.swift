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
                .foregroundStyle(Color.textSecondary)
                .frame(width: 32, height: 32)
                .background(Color.fillSubtle,
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.manrope, size: 14, weight: .semiBold)
                .foregroundStyle(Color.textSecondary)
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
                .foregroundStyle(Color.textPrimary.opacity(emphasized ? 1 : 0.6))
            Spacer(minLength: 8)
            Text(value)
                .font(.manrope, size: 14, weight: emphasized ? .extraBold : .semiBold)
                .foregroundStyle(Color.textPrimary)
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
                .foregroundStyle(Color.textTertiary)

            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .font(.manrope, size: 15, weight: .semiBold)
        .foregroundStyle(Color.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Capsule().fill(Color.cardSurface))
        .overlay(Capsule().strokeBorder(Color.hairline, lineWidth: 1))
    }
}

// MARK: - Error banner

struct FormErrorBanner: View {
    let message: String?

    var body: some View {
        if let message {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.manrope, size: 13, weight: .semiBold)
                .foregroundStyle(Color.negative)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.negative.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.opacity)
        }
    }
}

// MARK: - Primary button

/// Full-width capsule used for "Save" at the bottom of forms.
struct FormPrimaryButton: View {
    let title: String
    var tint: CustomColor = .accent
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.manrope, size: 20, weight: .extraBold)
                .foregroundStyle(Color.onAccent)
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

// MARK: - Section building blocks

extension View {
    /// The standard white content card: 20pt padding, full width, rounded.
    func sectionCard(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .finoraCard()
    }
}

/// Small uppercase caption above a block of content ("TOTAL SAVINGS").
struct SectionLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.manrope, size: 12, weight: .semiBold)
            .tracking(1)
            .foregroundStyle(Color.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

/// Title over value, used in rows of figures inside summary and detail cards.
struct StatColumn: View {
    let title: String
    let value: String
    var color: Color = .textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.manrope, size: 11, weight: .semiBold)
                .foregroundStyle(Color.textSecondary)
            Text(value)
                .font(.manrope, size: 15, weight: .bold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Friendly placeholder card for a list with nothing in it yet.
struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.textTertiary)

            Text(title)
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(Color.textPrimary)

            Text(message)
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}

/// Round "eye" button that toggles balance masking (backed by `AppSettings.hidesBalances`).
struct BalanceVisibilityButton: View {
    @Binding var isHidden: Bool

    var body: some View {
        Button {
            withAnimation(.smooth) { isHidden.toggle() }
        } label: {
            Image(systemName: isHidden ? "eye.slash" : "eye")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 44, height: 44)
                .background(Color.fillSubtle, in: Circle())
        }
        .accessibilityLabel(isHidden ? "Show balances" : "Hide balances")
    }
}

extension View {
    /// Text style for single-line values inside a `FormFieldRow`.
    func formFieldStyle() -> some View {
        self
            .font(.manrope, size: 15, weight: .semiBold)
            .foregroundStyle(Color.textPrimary)
    }
}
