//
//  AppSettings.swift
//  finora
//
//  Created by Shameem on 8/11/26.
//

import Foundation
import Observation


@Observable
@MainActor
final class AppSettings {
    
    // MARK: - Appearance

    
    // MARK: - App
    var language: AppLanguage = .system
    var notificationsEnabled: Bool = true
}



enum AppLanguage: String, CaseIterable, Equatable {
    case english
    case bengali
    case system
}
