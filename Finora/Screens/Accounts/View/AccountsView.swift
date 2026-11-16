//
//  AccountsView.swift
//  Finora
//
//  Screens/Accounts/View
//
//  Hosted by AccountsCoordinator inside its UINavigationController, so there is
//  no NavigationStack here: title bridges to the UIKit bar.
//

import SwiftUI

struct AccountsView<ViewModel: AccountsViewModelProtocol>: View {

    let model: ViewModel

    @State private var form: AccountFormViewModel?
    @State private var hideBalances = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    totalCard

                    if model.accounts.isEmpty {
                        emptyState
                    } else {
                        grid
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Accounts")
        .safeAreaInset(edge: .bottom) {
            AddActionButton(title: "Add New Account") {
                form = model.makeFormViewModel(editing: nil)
            }
        }
        .task { model.load() }
        .sheet(item: $form) { AccountFormView(form: $0) }
    }

    // MARK: - Total

    private var totalCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL BALANCE")
                    .font(.manrope, size: 12, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

                Text(hideBalances ? "৳ ••••••" : CurrencyFormatter.taka(model.totalBalance, showFraction: true))
                    .font(.manrope, size: 32, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                Text(model.accounts.count == 1 ? "1 account" : "\(model.accounts.count) accounts")
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
            }

            Spacer(minLength: 8)

            Button {
                withAnimation(.smooth) { hideBalances.toggle() }
            } label: {
                Image(systemName: hideBalances ? "eye.slash" : "eye")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(CustomColor.darkGray.color)
                    .frame(width: 44, height: 44)
                    .background(CustomColor.darkGray.color.opacity(0.06), in: Circle())
            }
            .accessibilityLabel(hideBalances ? "Show balances" : "Hide balances")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    // MARK: - Grid

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(model.accounts) { account in
                Button {
                    form = model.makeFormViewModel(editing: account)
                } label: {
                    AccountCard(account: account, hideBalance: hideBalances)
                        .shadow(color: Color(hex: account.tint).opacity(0.35), radius: 10, x: 0, y: 0)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Edit account")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.35))

            Text("No accounts yet")
                .font(.manrope, size: 18, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)

            Text("Add your bank, mobile wallet, card or cash to start tracking balances.")
                .font(.manrope, size: 14, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .finoraCard()
    }
}

#Preview {
    NavigationStack {
        AccountsView(model: AccountsViewModel(repository: InMemoryAccountRepository()))
    }
}
