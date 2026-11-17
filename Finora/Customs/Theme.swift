//
//  Theme.swift
//  Finora
//
//  Customs
//
//  One place for the semantic colours every screen uses, so features stay
//  visually consistent and a restyle is a one-file change. The raw palette
//  lives in `CustomColor` / `Colors.swift`.
//

import SwiftUI

extension Color {

    // MARK: Surfaces

    /// Screen background (`appBackground` is the underlying palette colour).
    static let screenBackground = Color.appBackground

    /// Faint fill for chips, icon wells and inactive controls.
    static let fillSubtle = CustomColor.darkGray.color.opacity(0.06)

    // MARK: Text

    static let textPrimary = CustomColor.darkGray.color
    static let textSecondary = CustomColor.darkGray.color.opacity(0.55)
    static let textTertiary = CustomColor.darkGray.color.opacity(0.4)

    // MARK: Meaning

    /// Money in / good news.
    static let positive = CustomColor.successGreen.color
    /// Money out / destructive.
    static let negative = CustomColor.dangerRed.color
    /// Primary call-to-action (add buttons, save buttons).
    static let accent = CustomColor.warmCoral.color
}

extension CustomColor {
    /// Default tint of primary actions across the app.
    static let accent: CustomColor = .warmCoral
    /// Tint of deposits / incoming money.
    static let incoming: CustomColor = .vividTeal
    /// Tint of withdrawals / outgoing money.
    static let outgoing: CustomColor = .warmCoral
}
