//
//  AppAppearance.swift
//  Finora
//
//  Customs
//
//  Applies the three-colour palette to UIKit chrome (tab bar, navigation bar,
//  window tint) so system controls match the SwiftUI screens.
//

import UIKit
import SwiftUI

enum AppAppearance {

    /// Call once at launch, before any controller is created.
    static func configure() {
        let secondary = UIColor(CustomColor.secondary.color)
        let primary = UIColor(CustomColor.primary.color)
        let accent = UIColor(CustomColor.accent.color)

        // Tab bar: teal surface, tangerine selection.
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = secondary
        tab.shadowColor = primary.withAlphaComponent(0.12)
        for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
            item.normal.iconColor = primary.withAlphaComponent(0.6)
            item.normal.titleTextAttributes = [.foregroundColor: primary.withAlphaComponent(0.6)]
            item.selected.iconColor = accent
            item.selected.titleTextAttributes = [.foregroundColor: accent]
        }
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        // Navigation bar: cream surface, teal text and controls.
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = primary
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: secondary]
        nav.largeTitleTextAttributes = [.foregroundColor: secondary]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = secondary
    }
}
