//
//  SavingsComponents.swift
//  Finora
//
//  Screens/Savings/View
//

import SwiftUI

/// Custom logo when one was picked, otherwise the tagged account's initial on the tint.
struct SavingsLogo: View {
    let name: String
    let tint: String
    let logoData: Data?
    var size: CGFloat = 46

    var body: some View {
        Group {
            if let logoData, let image = UIImage(data: logoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(hex: tint).opacity(0.15)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(Color(hex: tint))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
        .accessibilityHidden(true)
    }
}

/// One savings account in the list.
struct SavingsCard: View {
    let item: SavingsItem
    /// When both are set, quick "Add" / "Withdraw" buttons appear under the card.
    var onAdd: (() -> Void)?
    var onWithdraw: (() -> Void)?

    private var savings: SavingsAccount { item.savings }
    private var tint: Color { Color(hex: savings.tint) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            summary
            if let onAdd, let onWithdraw { actions(onAdd: onAdd, onWithdraw: onWithdraw) }
        }
        .padding(16)
        .contentShape(Rectangle())
        .finoraCard()
    }

    private func actions(onAdd: @escaping () -> Void, onWithdraw: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            quickButton(SavingsEntryKind.deposit, action: onAdd)
            quickButton(SavingsEntryKind.withdrawal, action: onWithdraw)
                .disabled(savings.currentSavings <= 0)
        }
    }

    private func quickButton(_ kind: SavingsEntryKind, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(kind == .deposit ? "Add" : "Withdraw", systemImage: kind.icon)
                .font(.manrope, size: 13, weight: .bold)
                .foregroundStyle(kind.tint.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(kind.tint.color.opacity(0.14), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                SavingsLogo(name: savings.name, tint: savings.tint, logoData: savings.logoData)

                VStack(alignment: .leading, spacing: 3) {
                    Text(savings.name)
                        .font(.manrope, size: 16, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .lineLimit(1)

                    Text(item.account.map { "in \($0.name)" } ?? "Account removed")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(CurrencyFormatter.taka(savings.currentSavings, showFraction: true))
                        .font(.manrope, size: 17, weight: .extraBold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if savings.isGoalReached {
                        Label("Goal reached", systemImage: "checkmark.seal.fill")
                            .font(.manrope, size: 11, weight: .bold)
                            .foregroundStyle(CustomColor.successGreen.color)
                    }
                }
            }

            if let progress = savings.progress, let target = savings.target {
                VStack(spacing: 6) {
                    ProgressBar(fraction: progress, color: tint)
                    HStack {
                        Text("\(Int((progress * 100).rounded()))% of \(CurrencyFormatter.taka(target))")
                        Spacer()
                        if let remaining = savings.remainingToTarget, remaining > 0 {
                            Text("\(CurrencyFormatter.taka(remaining)) to go")
                        }
                    }
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct SavingsEntryRow: View {
    let entry: SavingsEntry
    /// Shown above the details when the row appears outside its own savings account.
    var savingsName: String?

    private var source: String {
        guard let account = entry.account else { return "Outside accounts" }
        return "\(entry.kind == .deposit ? "From" : "To") \(account.name)"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.kind.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(entry.kind.tint.color)
                .frame(width: 36, height: 36)
                .background(entry.kind.tint.color.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                if let savingsName {
                    Text(savingsName)
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.45))
                        .lineLimit(1)
                }
                Text(entry.kind.historyTitle)
                    .font(.manrope, size: 14, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color)

                Text("\(source) · \(entry.date.formatted(.dateTime.day().month(.abbreviated).year()))")
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    .lineLimit(1)

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.45))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text("\(entry.kind.sign)\(CurrencyFormatter.taka(entry.amount, showFraction: true))")
                .font(.manrope, size: 15, weight: .extraBold)
                .foregroundStyle(entry.kind == .deposit ? CustomColor.successGreen.color : CustomColor.dangerRed.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
    }
}
