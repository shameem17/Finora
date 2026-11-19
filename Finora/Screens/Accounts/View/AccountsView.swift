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

    @State private var form: AccountFormViewModel?
    @State private var frontID: Account.ID?

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    totalCard

                    if model.accounts.isEmpty {
                        EmptyStateCard(icon: "creditcard",
                                       title: "No accounts yet",
                                       message: "Add your bank, mobile wallet, card or cash to start tracking balances.")
                    } else {
                        stack
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

    private var totalCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel("Total balance")

                Text(CurrencyFormatter.taka(model.totalBalance, showFraction: true))
                    .font(.manrope, size: 32, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                Text(model.accounts.count == 1 ? "1 account" : "\(model.accounts.count) accounts")
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            }

        }
        .sectionCard()
    }

    private var stack: some View {
        VStack(spacing: 20) {
            AccountCardStack(accounts: model.accounts,
                             frontID: $frontID) { account in
                form = model.makeFormViewModel(editing: account)
            }

            VStack(spacing: 0) {
                ForEach(model.accounts) { account in
                    accountRow(account)
                    if account.id != model.accounts.last?.id {
                        Divider().overlay(Color.hairline)
                    }
                }
            }
            .sectionCard(padding: 8)
        }
    }

    /// Compact list under the stack: tapping a row brings that card to the front.
    private func accountRow(_ account: Account) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) { frontID = account.id }
        } label: {
            HStack(spacing: 12) {
                AccountBadge(type: account.type, tint: account.tint, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.manrope, size: 15, weight: .bold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(account.type.title)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer(minLength: 8)

                Text(CurrencyFormatter.taka(account.balance, showFraction: true))
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Image(systemName: frontID == account.id ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(frontID == account.id ? Color.accent : Color.textTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AccountsView(model: AccountsViewModel(repository: InMemoryAccountRepository()))
    }
}
