//
//  df.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//

import SwiftUI

// MARK: - Model

enum AccountType: String {
    case bank = "Bank"
    case mfs = "MFS"
    case online = "Online"
    case virtual = "Virtual"
    case card = "Card"
    case cash = "Cash"

    var icon: String {
        switch self {
        case .bank:    return "building.columns.fill"
        case .mfs:     return "iphone.gen3"
        case .online:  return "globe"
        case .virtual: return "cube.transparent.fill"
        case .card:    return "creditcard.fill"
        case .cash:    return "banknote.fill"
        }
    }
}


// MARK: - Helpers

private extension Color {
    /// Slightly darker shade for the gradient end.
    func darker(_ amount: Double = 0.25) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: min(s + 0.05, 1), brightness: max(b - amount, 0), opacity: a)
    }
}

private func formatTaka(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.locale = Locale(identifier: "en_IN")   // lakh/crore grouping: 1,25,000
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 2
    return "৳" + (f.string(from: NSNumber(value: value)) ?? "0")
}

private func maskedNumber(_ number: String) -> String {
    let last4 = number.filter(\.isNumber).suffix(4)
    return "•••• \(last4)"
}

// MARK: - Card

struct AccountCard: View {
    let account: Account
    var hideBalance: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .top) {
                ProviderLogo(account: account)
                Spacer(minLength: 8)
                TypeChip(type: account.type)
            }

            Spacer(minLength: 12)

            // Name + account number
            VStack(alignment: .leading, spacing: 3) {
                Text(account.name)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(maskedNumber(account.number))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 14)

            // Balance
            VStack(alignment: .leading, spacing: 2) {
                Text("Balance")
                    .font(.caption2.weight(.medium))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.65))

                Text(hideBalance ? "৳ ••••••" : formatTaka(account.balance))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(CardBackground(tint: account.tint))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Pieces

struct CardBackground: View {
    let tint: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: tint), Color(hex: tint).darker(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft decorative circles for depth
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 150, height: 150)
                .offset(x: 70, y: -60)

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 110, height: 110)
                .offset(x: -80, y: 80)
        }
    }
}

private struct ProviderLogo: View {
    let account: Account

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)

            if let logo = account.logo, UIImage(named: logo) != nil {
                Image(logo)
                    .resizable()
                    .scaledToFit()
                    .padding(7)
            } else {
                // Fallback: first letters of the provider name
                Text(String(account.name.prefix(2)).uppercased())
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color(hex: account.tint))
            }
        }
        .frame(width: 42, height: 42)
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

private struct TypeChip: View {
    let type: AccountType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 9, weight: .bold))
            Text(type.rawValue)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.white.opacity(0.2), in: Capsule())
    }
}
