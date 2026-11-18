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

    /// `nonisolated` so the environment's default value can be created anywhere.
    nonisolated init() {}

    // MARK: - Appearance

    /// Currency used by every formatter in the app.
    var currency: AppCurrency = .bdt {
        didSet { AppCurrency.current = currency }
    }

    /// Masks balances everywhere (Home, Accounts…) when on. Remembered between launches.
    var hidesBalances: Bool = UserDefaults.standard.bool(forKey: SettingsKey.hidesBalances) {
        didSet { UserDefaults.standard.set(hidesBalances, forKey: SettingsKey.hidesBalances) }
    }

    // MARK: - App
    var language: AppLanguage = .system

    var notificationsEnabled: Bool = (UserDefaults.standard.object(forKey: SettingsKey.notifications) as? Bool) ?? true {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: SettingsKey.notifications) }
    }
}

nonisolated enum SettingsKey {
    static let hidesBalances = "finora.settings.hidesBalances"
    static let notifications = "finora.settings.notificationsEnabled"
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
