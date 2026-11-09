//
//  DeepLink.swift
//  finora
//
//  Created by finora on 9/8/26.
//

import Foundation

// MARK: - DeepLink

/// Type-safe representation of every navigable destination in the app.
/// Used by coordinators to route incoming URLs, push notification taps,
/// and universal links to the correct screen.
enum DeepLink: Equatable, Sendable {
    case home
    case quran(surahId: Int? = nil)
    case tracking(tab: String? = nil)
    case qibla
    case settings
    case bookmark
}
