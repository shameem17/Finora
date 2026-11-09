//
//  DeepLinkParser.swift
//  finora
//
//  Created by finora on 9/8/26.
//

import Foundation

// MARK: - DeepLinkParser

/// Parses incoming URLs into type-safe `DeepLink` values.
///
/// Supported schemes:
/// - Custom URL scheme:  `finora://quran?surah=36`
/// - Universal Link:     `https://finora.app/tracking?tab=salat`
///
/// The parser is a pure struct with no side effects, making it trivially testable.
struct DeepLinkParser {
    
    /// Attempts to parse the given URL into a `DeepLink`.
    /// Returns `nil` when the URL does not match any known route.
    static func parse(url: URL) -> DeepLink? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        // For custom scheme (finora://quran), `host` is the route.
        // For universal links (https://finora.app/quran), strip leading "/".
        let route: String? = {
            if let host = components.host, host != "finora.app" {
                return host.lowercased()
            }
            let path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return path.isEmpty ? nil : path.lowercased()
        }()
        
        guard let route else { return nil }
        
        let queryItems = components.queryItems ?? []
        
        switch route {
        case "home":
            return .home
            
        case "quran":
            let surahId = queryItems.first(where: { $0.name == "surah" })?.value.flatMap(Int.init)
            return .quran(surahId: surahId)
            
        case "tracking":
            let tab = queryItems.first(where: { $0.name == "tab" })?.value
            print("debug: tracking tab = \(tab ?? "nil")")
            return .tracking(tab: tab)
            
        case "qibla":
            return .qibla
            
        case "settings":
            return .settings
            
        case "bookmark", "bookmarks":
            return .bookmark
            
        default:
            return nil
        }
    }
    
    /// Attempts to parse a deep link from push notification `userInfo`.
    /// Expects a `"deeplink"` key whose value is a URL string.
    static func parse(userInfo: [AnyHashable: Any]) -> DeepLink? {
        guard let urlString = userInfo["deeplink"] as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        return parse(url: url)
    }
}
