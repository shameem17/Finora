//
//  Colors.swift
//  Finora
//
//  The whole app is drawn with three colours, in a 60 / 30 / 10 split:
//
//    primary    #F3EBDD  cream          ~60%  screen backgrounds, card surfaces
//    secondary  #013230  deep teal      ~30%  text, icons, hero cards, tab bar
//    accent     #F29A3A  tangerine      ~10%  buttons, the selected pill, highlights
//
//  Warm cream and tangerine balanced by cool teal. Anything a *user* themes
//  (an account, a savings pot, a category) keeps its own colour from the colour
//  picker; see `ColorSwatchPicker`.
//

import SwiftUI

enum CustomColor: String {
    case primary   = "#F3EBDD"
    case secondary = "#013230"
    case accent    = "#F29A3A"

    var color: Color { Color(hex: rawValue) }
}

extension Color {
    static let brandPrimary   = CustomColor.primary.color
    static let brandSecondary = CustomColor.secondary.color
    static let brandAccent    = CustomColor.accent.color
}

/// Hex strings for places that store a colour as text (user-themed items).
enum Palette {
    static let secondaryHex = CustomColor.secondary.rawValue
}

