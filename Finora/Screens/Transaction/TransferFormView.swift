//
//  TransferFormView.swift
//  Finora
//
//  Screens/Transaction/View
//

import SwiftUI

struct TransferFormView: View {

    @Bindable var form: TransferFormViewModel
    @State private var swapCount = 0

    var body: some View {
        FormSheet(title: "New Transfer",
                  primaryTitle: "Save Transfer",
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            accountsCard
            AmountField(title: "Amount", text: $form.amountText)
            detailsCard
            breakdown
            FormErrorBanner(message: form.visibleError)
        }
        .sensoryFeedback(.selection, trigger: swapCount)
    }

    // MARK: - Accounts

    private var accountsCard: some View {
        VStack(spacing: 0) {
            AccountDropdown(title: "From",
                            accounts: form.accounts,
                            selection: $form.fromID,
                            excluded: form.toID)

            HStack(spacing: 12) {
                Rectangle().fill(Color.fillSubtle).frame(height: 1)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        form.swapAccounts()
                    }
                    swapCount += 1
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.accent.opacity(0.25), in: Circle())
                }
                .accessibilityLabel("Swap accounts")

                Rectangle().fill(Color.fillSubtle).frame(height: 1)
            }
            .padding(.vertical, 6)

            AccountDropdown(title: "To",
                            accounts: form.accounts,
                            selection: $form.toID,
                            excluded: form.fromID)
        }
        .padding(16)
        .finoraCard()
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "percent", title: "Transaction charge") {
                HStack(spacing: 4) {
                    Text(CurrencyFormatter.symbol).foregroundStyle(Color.textTertiary)
                    TextField("0", text: $form.chargeText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                        .onChange(of: form.chargeText) { _, new in
                            let clean = DecimalInput.sanitize(new)
                            if clean != new { form.chargeText = clean }
                        }
                }
                .font(.manrope, size: 16, weight: .bold)
                .foregroundStyle(Color.textPrimary)
            }

            Divider()

            FormFieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date",
                           selection: $form.date,
                           in: ...Date.now,
                           displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.brandSecondary)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Reason (optional)", alignTop: true) {
                TextField("e.g. Rent, top-up…", text: $form.reason, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .formFieldStyle()
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    // MARK: - Breakdown / errors

    @ViewBuilder
    private var breakdown: some View {
        if let after = form.balanceAfter {
            VStack(spacing: 10) {
                ValueRow(title: "Amount",
                             value: CurrencyFormatter.taka(form.amount, showFraction: true))
                ValueRow(title: "Charge",
                             value: CurrencyFormatter.taka(form.charge, showFraction: true))
                Divider()
                ValueRow(title: "Total deducted",
                             value: CurrencyFormatter.taka(form.totalDebit, showFraction: true),
                             emphasized: true)
                ValueRow(title: "\(form.fromAccount?.name ?? "Source") balance after",
                             value: CurrencyFormatter.taka(after, showFraction: true))
            }
            .padding(16)
            .finoraCard(cornerRadius: 22)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

// MARK: - Dropdown

struct AccountDropdown: View {
    let title: String
    let accounts: [Account]
    @Binding var selection: Account.ID?
    let excluded: Account.ID?

    private var selected: Account? { accounts.first { $0.id == selection } }

    var body: some View {
        Menu {
            ForEach(accounts) { account in
                Button {
                    selection = account.id
                } label: {
                    let text = "\(account.name) · \(CurrencyFormatter.taka(account.balance, showFraction: true))"
                    if account.id == selection {
                        Label(text, systemImage: "checkmark")
                    } else {
                        Text(text)
                    }
                }
                .disabled(account.id == excluded)
            }
        } label: {
            HStack(spacing: 14) {
                if let selected {
                    AccountBadge(type: selected.type, tint: selected.tint, size: 44)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.textTertiary)
                        .frame(width: 44, height: 44)
                        .background(Color.fillSubtle,
                                    in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.uppercased())
                        .font(.manrope, size: 11, weight: .semiBold)
                        .tracking(1)
                        .foregroundStyle(Color.textSecondary)

                    Text(selected?.name ?? "Select account")
                        .font(.manrope, size: 16, weight: .bold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if let selected {
                        Text("Balance " + CurrencyFormatter.taka(selected.balance, showFraction: true))
                            .font(.manrope, size: 12, weight: .medium)
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .menuOrder(.fixed)
        .accessibilityLabel("\(title) account")
        .accessibilityValue(selected?.name ?? "None selected")
    }
}

#Preview {
    TransferFormView(form: TransferFormViewModel(
        accounts: InMemoryAccountRepository().fetchAccounts(),
        onSave: { _ in }
    ))
}
