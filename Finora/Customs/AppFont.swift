//
//  AppFont.swift
//  Finora
//
//  Created by Shameem on 11/9/26.
//

import SwiftUI


enum FontFamily {
    case poppins
    case manrope
    
    var name: String {
        switch self {
        case .poppins: return "Poppins"
        case .manrope: return "Manrope"
        }
    }
}


enum AppFontWeight {
    case extraLight, light, regular, medium, semiBold, bold, extraBold
    
    var suffix: String {
        switch self {
        case .extraLight: return "-ExtraLight"
        case .light:      return "-Light"
        case .regular:    return "-Regular"
        case .medium:     return "-Medium"
        case .semiBold:   return "-SemiBold"
        case .bold:       return "-Bold"
        case .extraBold:  return "-ExtraBold"
        }
    }
}


extension Font {
    static func appFont(_ family: FontFamily, size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        let fullFontName = "\(family.name)\(weight.suffix)"
        return .custom(fullFontName, size: size)
    }
}


struct AppFontModifier: ViewModifier {
    let family: FontFamily
    let size: CGFloat
    let weight: AppFontWeight
    
    func body(content: Content) -> some View {
        content
            .font(.appFont(family, size: size, weight: weight))
    }
}

extension View {
    func font(_ family: FontFamily, size: CGFloat, weight: AppFontWeight = .regular) -> some View {
        self.modifier(AppFontModifier(family: family, size: size, weight: weight))
    }
}
