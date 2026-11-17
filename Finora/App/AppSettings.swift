//
//  AppSettings.swift
//  finora
//
//  Created by Shameem on 8/11/26.
//

import Foundation
import Observation
import SwiftUI


@Observable
@MainActor
final class AppSettings {
    
    // MARK: - Appearance

    /// Currency used by every formatter in the app.
    var currency: AppCurrency = .bdt {
        didSet { AppCurrency.current = currency }
    }

    /// Masks balances everywhere (Home, Accounts…) when on.
    var hidesBalances: Bool = false

    // MARK: - App
    var language: AppLanguage = .system
    var notificationsEnabled: Bool = true
}



enum AppLanguage: String, CaseIterable, Equatable {
    case english
    case bengali
    case system
}


/// Currency shown across the app. `current` is kept in sync by `AppSettings`
/// so plain formatters don't need the settings object injected.
enum AppCurrency: String, CaseIterable {
    case bdt

    nonisolated(unsafe) static var current: AppCurrency = .bdt

    var symbol: String {
        switch self {
        case .bdt: return "৳"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .bdt: return "en_IN"   // lakh / crore grouping: 1,25,000
        }
    }
}

// MARK: - Environment

extension EnvironmentValues {
    /// The shared settings object. Coordinators inject the real one with
    /// `.environment(\.appSettings, settings)`; previews fall back to defaults.
    @Entry var appSettings = AppSettings()
}
