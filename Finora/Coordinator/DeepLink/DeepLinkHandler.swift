//
//  DeepLinkHandler.swift
//  finora
//
//  Created by finora on 9/8/26.
//

import Foundation

// MARK: - DeepLinkHandling

/// Protocol for any coordinator that can route a `DeepLink` to the appropriate screen.
protocol DeepLinkHandling {
    func handle(deepLink: DeepLink)
}
