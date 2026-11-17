//
//  CurrencyFormatter.swift
//  Finora
//
//  Services/Currency
//

import Foundation

/// Shared money formatting for the app's current currency (see `AppSettings.currency`).
/// `NumberFormatter` is expensive to create, so the two variants are built once and reused.
enum CurrencyFormatter {

    /// Symbol of the current currency, e.g. "৳".
    static var symbol: String { AppCurrency.current.symbol }

    /// What a masked balance looks like.
    static var hidden: String { "\(symbol) ••••••" }

    private static let whole = makeFormatter(maxFractionDigits: 0)
    private static let fractional = makeFormatter(maxFractionDigits: 2)

    static func taka(_ value: Double, showFraction: Bool = false) -> String {
        let formatter = showFraction ? fractional : whole
        return symbol + (formatter.string(from: NSNumber(value: value)) ?? "0")
    }

    private static func makeFormatter(maxFractionDigits: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: AppCurrency.current.localeIdentifier)
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = maxFractionDigits
        return f
    }
}

/// Keeps numeric text fields clean: digits plus one decimal separator.
enum DecimalInput {
    static func sanitize(_ raw: String, maxFractionDigits: Int = 2, maxLength: Int = 12) -> String {
        var result = ""
        var hasSeparator = false
        var fractionCount = 0

        for ch in raw.replacingOccurrences(of: ",", with: ".") {
            if ch.isASCII, ch.isNumber {
                if hasSeparator {
                    guard fractionCount < maxFractionDigits else { continue }
                    fractionCount += 1
                }
                result.append(ch)
            } else if ch == ".", !hasSeparator {
                hasSeparator = true
                result.append(ch)
            }
            if result.count >= maxLength { break }
        }
        return result
    }

    static func value(of text: String) -> Double {
        Double(text) ?? 0
    }

    /// Editable text for an amount: whole numbers without decimals, otherwise two.
    static func text(_ value: Double) -> String {
        value.formatted(
            .number
                .locale(Locale(identifier: "en_US_POSIX"))
                .grouping(.never)
                .precision(.fractionLength(0...2))
        )
    }
}
