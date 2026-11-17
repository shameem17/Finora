//
//  AccountFormView.swift
//  Finora
//
//  Screens/Accounts/View
//

import SwiftUI

struct AccountFormView: View {

    @Bindable var form: AccountFormViewModel

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.isEditing ? "Save Changes" : "Save Account",
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            AccountCard(account: form.draft)
                .shadow(color: Color(hex: form.tintHex).opacity(0.35), radius: 10)
                .animation(.smooth, value: form.tintHex)
                .accessibilityHidden(true)

            detailsCard

            LogoColorPickerCard(tintHex: $form.tintHex,
                                hasLogo: form.hasLogo,
                                isProcessing: form.isProcessingLogo,
                                onPickImage: { await form.setLogo(fromImageData: $0) },
                                onRemove: form.removeLogo)

            AmountField(title: "Initial balance", text: $form.initialBalanceText, fontSize: 34)

            currentBalanceCard
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "textformat", title: "Name") {
                TextField("e.g. City Bank", text: $form.name)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.words)
                    .formFieldStyle()
            }

            Divider()

            FormFieldRow(icon: "number", title: "Account no.") {
                TextField("Optional", text: $form.number)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .formFieldStyle()
            }

            Divider()

            FormFieldRow(icon: "square.grid.2x2", title: "Type") {
                Picker("Type", selection: $form.type) {
                    ForEach(AccountType.selectable) { type in
                        Label(type.title, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.textPrimary)
                .labelsHidden()
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    /// Read-only: it is always initial balance + recorded movement.
    private var currentBalanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Current balance", systemImage: "lock.fill")
                    .font(.manrope, size: 14, weight: .semiBold)
                    .foregroundStyle(Color.textSecondary)

                Spacer(minLength: 8)

                Text(CurrencyFormatter.taka(form.currentBalance, showFraction: true))
                    .font(.manrope, size: 16, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
            }

            Text(form.isEditing
                 ? "Calculated from your initial balance plus every transfer, loan, savings and payment. It can't be edited directly."
                 : "Starts equal to the initial balance, then updates automatically as you record activity.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
        .sectionCard()
    }
}

#Preview {
    AccountFormView(form: AccountFormViewModel(mode: .create, repository: InMemoryAccountRepository()))
}
