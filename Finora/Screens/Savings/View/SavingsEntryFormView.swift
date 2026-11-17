//
//  SavingsEntryFormView.swift
//  Finora
//
//  Screens/Savings/View
//
//  One form for "Add Savings", "Withdraw" (break savings) and editing an entry.
//

import SwiftUI

struct SavingsEntryFormView: View {

    @Bindable var form: SavingsEntryFormViewModel

    private var kind: SavingsEntryKind { form.kind }

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.saveTitle,
                  tint: kind.tint,
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            headerCard

            AmountField(title: "Amount", text: $form.amountText) {
                if kind == .withdrawal {
                    AmountChip(title: "Break all · \(CurrencyFormatter.taka(form.current, showFraction: true))",
                               tint: kind.tint.color) {
                        Keyboard.dismiss()
                        form.withdrawAll()
                    }
                }
            }

            accountCard
            detailsCard
            breakdown
            FormErrorBanner(message: form.visibleError)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            SavingsLogo(name: form.savings.name, tint: form.savings.tint,
                        logoData: form.savings.logoData, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(form.savings.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("Saved: \(CurrencyFormatter.taka(form.current, showFraction: true))")
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .accessibilityElement(children: .combine)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $form.usesAccount.animation(.smooth)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind == .deposit ? "Take from an account" : "Add to an account")
                        .font(.manrope, size: 15, weight: .bold)
                        .foregroundStyle(Color.textPrimary)
                    Text(accountCaption)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .tint(CustomColor.incoming.color)
            .disabled(form.accounts.isEmpty)

            if form.usesAccount {
                AccountDropdown(title: kind.accountTitle,
                                accounts: form.accounts,
                                selection: $form.accountID,
                                excluded: nil)
            }
        }
        .padding(16)
        .finoraCard()
    }

    private var accountCaption: String {
        if form.usesAccount { return "The chosen account's balance is updated." }
        return kind == .deposit ? "Recorded only. No account balance changes."
                                : "Recorded only. The money isn't added to any account."
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date", selection: $form.date,
                           in: form.earliestDate...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.accent)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField(kind == .deposit ? "e.g. Monthly saving" : "e.g. Medical emergency",
                          text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .formFieldStyle()
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    @ViewBuilder
    private var breakdown: some View {
        if let after = form.savingsAfter {
            VStack(spacing: 10) {
                ValueRow(title: "Amount", value: CurrencyFormatter.taka(form.amount, showFraction: true))
                Divider()
                ValueRow(title: "Savings after",
                         value: CurrencyFormatter.taka(max(after, 0), showFraction: true),
                         emphasized: true)

                if let balance = form.balanceAfter, let account = form.account {
                    ValueRow(title: "\(account.name) balance after",
                             value: CurrencyFormatter.taka(balance, showFraction: true))
                }
            }
            .padding(16)
            .finoraCard(cornerRadius: 22)
        }
    }
}

#Preview {
    let dependencies = SavingsDependencies.preview()
    if let savings = dependencies.savings.fetchSavings().first {
        SavingsEntryFormView(form: SavingsEntryFormViewModel(mode: .create(.withdrawal), savings: savings, dependencies: dependencies))
    }
}
