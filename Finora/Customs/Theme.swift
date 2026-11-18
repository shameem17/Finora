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

    // MARK: Surfaces (secondary violet, dark style)

    /// Screen background: deep violet.
    static let screenBackground = Color.brandSecondary

    /// Cards and fields: the light primary laid over violet at low opacity.
    static let cardSurface = Color.brandPrimary.opacity(0.09)

    /// Faint fill for chips, icon wells and inactive controls.
    static let fillSubtle = Color.brandPrimary.opacity(0.10)

    /// Hairline borders on cards.
    static let hairline = Color.brandPrimary.opacity(0.10)

    // MARK: Text and icons (primary)

    static let textPrimary = Color.brandPrimary
    static let textSecondary = Color.brandPrimary.opacity(0.68)
    static let textTertiary = Color.brandPrimary.opacity(0.45)

    // MARK: Accent (lime, ~10%)

    /// Buttons, the selected pill, highlights. Always paired with `onAccent` text.
    static let accent = Color.brandAccent
    static let onAccent = Color.brandSecondary

    // MARK: Hero cards (light card on the dark screen)

    static let heroSurface = Color.brandPrimary
    static let onHero = Color.brandSecondary
    static let onHeroSecondary = Color.brandSecondary.opacity(0.65)

    // MARK: Money

    /// Money in. Colour is not used to tell in from out; signs and icons do.
    static let positive = Color.brandAccent
    /// Money out / warnings.
    static let negative = Color.brandPrimary.opacity(0.7)
}

extension View {

    /// Light summary card with violet text (use `Color.onHero` inside).
    func heroCard(cornerRadius: CGFloat = 28) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.heroSurface)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}
