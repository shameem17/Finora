//
//  SavingsEntryFormView.swift
//  Finora
//
//  Screens/Savings/View
//
//  One form for both "Add Savings" and "Withdraw" (break savings).
//

import SwiftUI

struct SavingsEntryFormView: View {

    @Bindable var form: SavingsEntryFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?

    private enum Field: Hashable { case amount, note }

    private var kind: SavingsEntryKind { form.kind }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerCard
                        amountCard
                        accountCard
                        detailsCard
                        breakdown
                        FormErrorBanner(message: form.visibleError)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: form.visibleError)
                    .animation(.smooth, value: form.amount > 0)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(form.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.manrope, size: 16, weight: .semiBold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = nil }
                }
            }
            .safeAreaInset(edge: .bottom) {
                FormPrimaryButton(title: form.saveTitle, tint: kind.tint, isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            SavingsLogo(name: form.savings.name, tint: form.savings.tint,
                        logoData: form.savings.logoData, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(form.savings.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .lineLimit(1)

                Text("Saved: \(CurrencyFormatter.taka(form.current, showFraction: true))")
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.6))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .accessibilityElement(children: .combine)
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AMOUNT")
                .font(.manrope, size: 12, weight: .semiBold)
                .tracking(1)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))

            HStack(spacing: 6) {
                Text("৳")
                    .font(.manrope, size: 36, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))

                TextField("0", text: $form.amountText)
                    .font(.manrope, size: 40, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .keyboardType(.decimalPad)
                    .focused($focused, equals: .amount)
                    .minimumScaleFactor(0.5)
                    .onChange(of: form.amountText) { _, new in
                        let clean = DecimalInput.sanitize(new)
                        if clean != new { form.amountText = clean }
                    }
            }

            if kind == .withdrawal {
                Button {
                    focused = nil
                    form.withdrawAll()
                } label: {
                    Text("Break all · \(CurrencyFormatter.taka(form.current, showFraction: true))")
                        .font(.manrope, size: 12, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(kind.tint.color.opacity(0.18), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .amount }
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $form.usesAccount.animation(.smooth)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind == .deposit ? "Take from an account" : "Add to an account")
                        .font(.manrope, size: 15, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                    Text(form.usesAccount
                         ? "The chosen account's balance is updated."
                         : (kind == .deposit ? "Recorded only. No account balance changes."
                                             : "Recorded only. The money isn't added to any account."))
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                }
            }
            .tint(CustomColor.vividTeal.color)
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

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date", selection: $form.date,
                           in: form.earliestDate...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(CustomColor.vividTeal.color)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField(kind == .deposit ? "e.g. Monthly saving" : "e.g. Medical emergency",
                          text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .focused($focused, equals: .note)
                    .submitLabel(.done)
                    .onSubmit { focused = nil }
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
                ValueRow(title: "Savings after", value: CurrencyFormatter.taka(max(after, 0), showFraction: true), emphasized: true)

                if let balance = form.balanceAfter, let account = form.account {
                    ValueRow(title: "\(account.name) balance after",
                             value: CurrencyFormatter.taka(balance, showFraction: true))
                }
            }
            .padding(16)
            .finoraCard(cornerRadius: 22)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

#Preview {
    let dependencies = SavingsDependencies.preview()
    if let savings = dependencies.savings.fetchSavings().first {
        SavingsEntryFormView(form: SavingsEntryFormViewModel(mode: .create(.withdrawal), savings: savings, dependencies: dependencies))
    }
}
