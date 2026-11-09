//
//  Colors + Extension.swift
//  Mumin
//
//  Created by Shameem on 8/2/26.
//


import SwiftUI

extension Color {
    init(hex: String?) {
        // Clean the string by removing whitespaces and the '#' prefix
        let hex: String = hex ?? "000000"
        let cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let r, g, b, a: Double
        
        switch cleanedHex.count {
        case 3: // RGB (12-bit) - e.g., "FFF"
            r = Double((rgb >> 8) & 0xF) / 15.0
            g = Double((rgb >> 4) & 0xF) / 15.0
            b = Double(rgb & 0xF) / 15.0
            a = 1.0
        case 6: // RGB (24-bit) - e.g., "FF0000"
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        case 8: // RGBA (32-bit) - e.g., "FF0000FF"
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        default: // Invalid format defaults to clear color
            r = 0.0; g = 0.0; b = 0.0; a = 0.0
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

