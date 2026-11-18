//
//  Theme.swift
//  Finora
//
//  Customs
//
//  Semantic colours built from the three palette colours in `Colors.swift`.
//  Screens use these names, never raw hex values, so a restyle is a one-file
//  change and every feature stays visually consistent.
//

import SwiftUI

extension Color {

    // MARK: Surfaces (primary, ~60%)

    /// Screen background.
    static let screenBackground = Color.brandPrimary

    /// Cards and fields: the primary colour lifted towards white.
    static let cardSurface = Color.white.opacity(0.72)

    /// Faint fill for chips, icon wells and inactive controls.
    static let fillSubtle = Color.brandSecondary.opacity(0.07)

    // MARK: Text and icons (secondary, ~30%)

    static let textPrimary = Color.brandSecondary
    static let textSecondary = Color.brandSecondary.opacity(0.62)
    static let textTertiary = Color.brandSecondary.opacity(0.4)

    // MARK: Accent (~10%)

    /// Buttons, the selected pill, highlights. Always paired with `onAccent` text.
    static let accent = Color.brandAccent
    static let onAccent = Color.brandSecondary

    // MARK: Hero cards (secondary as a surface)

    static let heroSurface = Color.brandSecondary
    static let onHero = Color.brandPrimary
    static let onHeroSecondary = Color.brandPrimary.opacity(0.7)

    // MARK: Money

    /// Money in. Colour is not used to tell in from out; signs and icons do.
    static let positive = Color.brandSecondary
    /// Money out / warnings.
    static let negative = Color.brandSecondary.opacity(0.7)
}

extension View {

    /// Deep-violet summary card with light text (use `Color.onHero` inside).
    func heroCard(cornerRadius: CGFloat = 28) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.heroSurface)
            )
            .shadow(color: Color.brandSecondary.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}
