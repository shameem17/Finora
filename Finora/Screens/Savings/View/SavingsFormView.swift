//
//  SavingsFormView.swift
//  Finora
//
//  Screens/Savings/View
//

import SwiftUI

struct SavingsFormView: View {

    @Bindable var form: SavingsFormViewModel

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.saveTitle,
                  tint: .accent,
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            SavingsCard(item: SavingsItem(savings: form.draft,
                                          account: form.account.map(AccountSummary.init)))
                .accessibilityHidden(true)

            accountCard
            detailsCard
            goalCard

            if !form.isEditing {
                AmountField(title: "Already saved (optional)", text: $form.openingText, fontSize: 34) {
                    Text("Money you've already put aside. It won't be deducted from any account.")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            LogoColorPickerCard(tintHex: $form.tintHex,
                                hasLogo: form.hasLogo,
                                isProcessing: form.isProcessingLogo,
                                onPickImage: { await form.setLogo(fromImageData: $0) },
                                onRemove: form.removeLogo)
        }
    }

    // MARK: - Cards

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AccountDropdown(title: "Tagged account",
                            accounts: form.accounts,
                            selection: $form.accountID,
                            excluded: nil)
            Text("Deposits are taken from, and withdrawals returned to, accounts you choose each time. This one is the default.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .finoraCard()
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "textformat", title: "Name") {
                TextField("e.g. City Bank Savings", text: $form.name)
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

            FormFieldRow(icon: "calendar", title: "Start date") {
                DatePicker("Start date", selection: $form.startDate,
                           in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.brandAccent)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note", alignTop: true) {
                TextField("Optional", text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .formFieldStyle()
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    private var goalCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "flag.checkered", title: "Target") {
                HStack(spacing: 4) {
                    Text(CurrencyFormatter.symbol).foregroundStyle(Color.textTertiary)
                    TextField("Optional", text: $form.targetText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 130)
                        .onChange(of: form.targetText) { _, new in
                            let clean = DecimalInput.sanitize(new)
                            if clean != new { form.targetText = clean }
                        }
                }
                .font(.manrope, size: 16, weight: .bold)
                .foregroundStyle(Color.textPrimary)
            }

            Divider()

            FormFieldRow(icon: "calendar.badge.clock", title: "Set a target date") {
                Toggle("Set a target date", isOn: $form.hasTargetDate.animation(.smooth))
                    .labelsHidden()
                    .tint(Color.brandAccent)
            }

            if form.hasTargetDate {
                Divider()
                FormFieldRow(icon: "flag.fill", title: "Target date") {
                    DatePicker("Target date", selection: $form.targetDate,
                               in: form.startDate..., displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.brandAccent)
                }
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }
}

#Preview {
    SavingsFormView(form: SavingsFormViewModel(mode: .create, dependencies: .preview()))
}
