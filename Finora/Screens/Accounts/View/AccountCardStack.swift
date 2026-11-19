//
//  AccountCardStack.swift
//  Finora
//
//  Screens/Accounts/View
//
//  Accounts as a stack of bank cards. The front card shows its face; tapping it
//  flips it to the back. Cards behind show their backs, peeking out above the
//  front card: tapping one flips it round to the front, and swiping the front
//  card sends it to the back of the stack.
//

import SwiftUI

// MARK: - Flip

/// Two faces on one card. `angle` is animatable, so the face swaps exactly
/// half-way through the rotation instead of at the start or the end.
struct FlipCard<Front: View, Back: View>: View, Animatable {

    var angle: Double
    private let front: Front
    private let back: Back

    init(angle: Double,
         @ViewBuilder front: () -> Front,
         @ViewBuilder back: () -> Back) {
        self.angle = angle
        self.front = front()
        self.back = back()
    }

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    private var showsFront: Bool { angle.truncatingRemainder(dividingBy: 360) < 90 }

    var body: some View {
        ZStack {
            front.opacity(showsFront ? 1 : 0)
            back
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(showsFront ? 0 : 1)
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
    }
}

// MARK: - Stack

struct AccountCardStack: View {

    let accounts: [Account]
    @Binding var frontID: Account.ID?
    var hidesBalances = false
    let onEdit: (Account) -> Void

    /// Cards that have been flipped to show their back while at the front.
    @State private var flippedFront: Set<Account.ID> = []
    @State private var dragOffset: CGFloat = 0

    private let cardHeight: CGFloat = 200
    private let peek: CGFloat = 16
    private let maxVisible = 4

    /// The accounts, rotated so the front card comes first.
    private var ordered: [Account] {
        guard let id = frontID, let index = accounts.firstIndex(where: { $0.id == id }) else {
            return accounts
        }
        return Array(accounts[index...] + accounts[..<index])
    }

    var body: some View {
        let visible = Array(ordered.prefix(maxVisible))

        VStack(spacing: 14) {
            ZStack(alignment: .bottom) {
                ForEach(Array(visible.enumerated()), id: \.element.id) { position, account in
                    card(for: account, at: position)
                }
            }
            .frame(height: cardHeight + peek * CGFloat(max(visible.count - 1, 0)))
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: frontID)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: flippedFront)

            footer
        }
        .onAppear(perform: ensureFront)
        .onChange(of: accounts.map(\.id)) { _, _ in ensureFront() }
    }

    // MARK: Cards

    private func card(for account: Account, at position: Int) -> some View {
        let isFront = position == 0
        // The front card faces forward unless flipped; every card behind shows its back.
        let angle: Double = (isFront && !flippedFront.contains(account.id)) ? 0 : 180

        return FlipCard(angle: angle) {
            AccountCard(account: account, hideBalance: hidesBalances)
                .frame(height: cardHeight)
        } back: {
            AccountCardBack(account: account, hideBalance: hidesBalances)
                .frame(height: cardHeight)
        }
        .shadow(color: Color.brandSecondary.opacity(isFront ? 0.25 : 0.12), radius: isFront ? 14 : 6, y: 6)
        .scaleEffect(1 - CGFloat(position) * 0.05, anchor: .bottom)
        .offset(x: isFront ? dragOffset : 0, y: -CGFloat(position) * peek)
        .rotationEffect(.degrees(isFront ? Double(dragOffset) / 40 : 0), anchor: .bottom)
        .zIndex(Double(-position))
        .onTapGesture { tap(account, isFront: isFront) }
        .gesture(swipe, including: isFront ? .all : .none)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name), \(account.type.title)")
        .accessibilityHint(isFront ? "Double tap to flip the card" : "Double tap to bring to front")
        .accessibilityAddTraits(.isButton)
    }

    private var footer: some View {
        HStack {
            Text(counterText)
                .font(.manrope, size: 13, weight: .semiBold)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            if let front = ordered.first {
                Button { onEdit(front) } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.manrope, size: 13, weight: .bold)
                        .foregroundStyle(Color.onAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
    }

    private var counterText: String {
        guard let id = frontID, let index = accounts.firstIndex(where: { $0.id == id }) else { return "" }
        return "\(index + 1) of \(accounts.count) · tap to flip, swipe to switch"
    }

    // MARK: Interaction

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 16)
            .onChanged { dragOffset = $0.translation.width }
            .onEnded { value in
                let shouldAdvance = abs(value.translation.width) > 70 && accounts.count > 1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    dragOffset = 0
                    if shouldAdvance { advance() }
                }
            }
    }

    private func tap(_ account: Account, isFront: Bool) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            if isFront {
                if flippedFront.contains(account.id) { flippedFront.remove(account.id) }
                else { flippedFront.insert(account.id) }
            } else {
                // Arrives face-up: its back rotates round to the front.
                flippedFront.remove(account.id)
                frontID = account.id
            }
        }
    }

    /// Sends the front card to the back of the stack.
    private func advance() {
        guard ordered.count > 1 else { return }
        flippedFront.removeAll()
        frontID = ordered[1].id
    }

    private func ensureFront() {
        if frontID == nil || !accounts.contains(where: { $0.id == frontID }) {
            frontID = accounts.first?.id
        }
        flippedFront.formIntersection(Set(accounts.map(\.id)))
    }
}

// MARK: - Back face

struct AccountCardBack: View {
    let account: Account
    var hideBalance = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Magnetic stripe.
            Rectangle()
                .fill(Color.black.opacity(0.35))
                .frame(height: 38)
                .padding(.top, 22)

            VStack(alignment: .leading, spacing: 14) {
                detail("Account number", value: hideBalance ? "•••• •••• ••••" : spaced(account.number))
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))

                HStack(alignment: .top, spacing: 12) {
                    labelled("Type", account.type.title)
                    labelled("Opening", money(account.initialBalance))
                    labelled("Activity", movement(account.balance - account.initialBalance))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(tint: account.tint))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func detail(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.weight(.medium))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.65))
            Text(value)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func labelled(_ title: String, _ value: String) -> some View {
        detail(title, value: value)
            .font(.system(.footnote, design: .rounded, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func money(_ value: Double) -> String {
        hideBalance ? CurrencyFormatter.hidden : CurrencyFormatter.taka(value)
    }

    private func movement(_ value: Double) -> String {
        guard !hideBalance else { return CurrencyFormatter.hidden }
        let sign = value > 0 ? "+" : (value < 0 ? "−" : "")
        return sign + CurrencyFormatter.taka(abs(value))
    }

    /// "1234567894821" → "1234 5678 9482 1".
    private func spaced(_ number: String) -> String {
        let digits = number.filter { !$0.isWhitespace }
        guard !digits.isEmpty else { return "No account number" }
        return stride(from: 0, to: digits.count, by: 4).map { start in
            let from = digits.index(digits.startIndex, offsetBy: start)
            let to = digits.index(from, offsetBy: min(4, digits.count - start))
            return String(digits[from..<to])
        }.joined(separator: " ")
    }
}
