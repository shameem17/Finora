//
//  Colors.swift
//  Finora
//
//  The whole app is drawn with three colours, in a 60 / 30 / 10 split:
//
//    primary    #F4F2F6  soft white   ~60%  screen backgrounds, card surfaces
//    secondary  #3F066D  deep violet  ~30%  text, hero cards, tab bar, icons
//    accent     #C3F53A  electric lime ~10%  buttons, the selected pill, highlights
//
//  Anything a *user* themes (an account, a savings pot, a category) keeps its own
//  colour from the colour picker; see `ColorSwatchPicker`.
//

import SwiftUI

enum CustomColor: String {
    case primary   = "#F4F2F6"
    case secondary = "#3F066D"
    case accent    = "#C3F53A"

    var color: Color { Color(hex: rawValue) }
}

extension Color {
    static let brandPrimary   = CustomColor.primary.color
    static let brandSecondary = CustomColor.secondary.color
    static let brandAccent    = CustomColor.accent.color

    // Names older screens still use.
    static let appBackground = Color.brandPrimary
    static let customBlack   = Color.brandSecondary
    static let firstStepBackground  = Color.brandPrimary
    static let secondStepBackground = Color.brandPrimary
    static let thirdStepBackground  = Color.brandPrimary
}

/// Hex strings for places that store a colour as text (user-themed items).
enum Palette {
    static let secondaryHex = CustomColor.secondary.rawValue
    static let accentHex = CustomColor.accent.rawValue
}

extension String {
    func toColor() -> Color {
        return Color(hex: self)
    }
}
