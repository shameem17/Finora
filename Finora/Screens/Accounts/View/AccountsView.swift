//
//  AccountsView.swift
//  Finora
//
//  Screens/Accounts/View
//
//  Hosted by AccountsCoordinator inside its UINavigationController, so there is
//  no NavigationStack here: the title bridges to the UIKit bar.
//

import SwiftUI

struct AccountsView<ViewModel: AccountsViewModelProtocol>: View {

    let model: ViewModel

    @Environment(\.appSettings) private var settings
    @State private var form: AccountFormViewModel?

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    totalCard(isHidden: $settings.hidesBalances)

                    if model.accounts.isEmpty {
                        EmptyStateCard(icon: "creditcard",
                                       title: "No accounts yet",
                                       message: "Add your bank, mobile wallet, card or cash to start tracking balances.")
                    } else {
                        grid(hidesBalances: settings.hidesBalances)
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

    private func totalCard(isHidden: Binding<Bool>) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel("Total balance")

                Text(isHidden.wrappedValue ? CurrencyFormatter.hidden
                                           : CurrencyFormatter.taka(model.totalBalance, showFraction: true))
                    .font(.manrope, size: 32, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                Text(model.accounts.count == 1 ? "1 account" : "\(model.accounts.count) accounts")
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 8)

            BalanceVisibilityButton(isHidden: isHidden)
        }
        .sectionCard()
    }

    private func grid(hidesBalances: Bool) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(model.accounts) { account in
                Button {
                    form = model.makeFormViewModel(editing: account)
                } label: {
                    AccountCard(account: account, hideBalance: hidesBalances)
                        .shadow(color: Color(hex: account.tint).opacity(0.35), radius: 10, x: 0, y: 0)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Edit account")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountsView(model: AccountsViewModel(repository: InMemoryAccountRepository()))
    }
}
