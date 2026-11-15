//
//  TransferFormView.swift
//  Finora
//
//  Screens/Transaction/View
//

import SwiftUI

struct TransferFormView: View {

    @Bindable var form: TransferFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?
    @State private var swapCount = 0

    private enum Field: Hashable { case amount, charge, reason }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        accountsCard
                        amountCard
                        detailsCard
                        breakdown
                        errorBanner
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: form.visibleError)
                    .animation(.smooth, value: form.balanceAfter == nil)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New Transfer")
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
            .safeAreaInset(edge: .bottom) { saveButton }
        }
        .presentationDragIndicator(.visible)
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
                Rectangle().fill(CustomColor.darkGray.color.opacity(0.08)).frame(height: 1)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        form.swapAccounts()
                    }
                    swapCount += 1
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(CustomColor.darkGray.color)
                        .frame(width: 36, height: 36)
                        .background(CustomColor.warmCoral.color.opacity(0.25), in: Circle())
                }
                .accessibilityLabel("Swap accounts")

                Rectangle().fill(CustomColor.darkGray.color.opacity(0.08)).frame(height: 1)
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

    // MARK: - Amount

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
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
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .amount }
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FieldRow(icon: "percent", title: "Transaction charge") {
                HStack(spacing: 4) {
                    Text("৳").foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
                    TextField("0", text: $form.chargeText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focused, equals: .charge)
                        .frame(maxWidth: 110)
                        .onChange(of: form.chargeText) { _, new in
                            let clean = DecimalInput.sanitize(new)
                            if clean != new { form.chargeText = clean }
                        }
                }
                .font(.manrope, size: 16, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
            }

            Divider()

            FieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date",
                           selection: $form.date,
                           in: ...Date.now,
                           displayedComponents: .date)
                    .labelsHidden()
                    .tint(CustomColor.warmCoral.color)
            }

            Divider()

            FieldRow(icon: "text.alignleft", title: "Reason (optional)", alignTop: true) {
                TextField("e.g. Rent, top-up…", text: $form.reason, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .focused($focused, equals: .reason)
                    .submitLabel(.done)
                    .onSubmit { focused = nil }
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
                TransactionBreakdownRow(title: "Amount",
                             value: CurrencyFormatter.taka(form.amount, showFraction: true))
                TransactionBreakdownRow(title: "Charge",
                             value: CurrencyFormatter.taka(form.charge, showFraction: true))
                Divider()
                TransactionBreakdownRow(title: "Total deducted",
                             value: CurrencyFormatter.taka(form.totalDebit, showFraction: true),
                             emphasized: true)
                TransactionBreakdownRow(title: "\(form.fromAccount?.name ?? "Source") balance after",
                             value: CurrencyFormatter.taka(after, showFraction: true))
            }
            .padding(16)
            .finoraCard(cornerRadius: 22)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let message = form.visibleError {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.manrope, size: 13, weight: .semiBold)
                .foregroundStyle(CustomColor.dangerRed.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(CustomColor.dangerRed.color.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.opacity)
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            focused = nil
            if form.submit() { dismiss() }
        } label: {
            Text("Save Transfer")
                .font(.manrope, size: 20, weight: .extraBold)
                .foregroundStyle(CustomColor.darkGray.color)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(CustomColor.warmCoral.color)
                .clipShape(Capsule())
                .shadow(color: CustomColor.warmCoral.color.opacity(0.4), radius: 12, y: 6)
        }
        .disabled(!form.canSubmit)
        .opacity(form.canSubmit ? 1 : 0.45)
        .animation(.easeInOut(duration: 0.2), value: form.canSubmit)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
                        .frame(width: 44, height: 44)
                        .background(CustomColor.darkGray.color.opacity(0.06),
                                    in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.uppercased())
                        .font(.manrope, size: 11, weight: .semiBold)
                        .tracking(1)
                        .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))

                    Text(selected?.name ?? "Select account")
                        .font(.manrope, size: 16, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .lineLimit(1)

                    if let selected {
                        Text("Balance " + CurrencyFormatter.taka(selected.balance, showFraction: true))
                            .font(.manrope, size: 12, weight: .medium)
                            .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .menuOrder(.fixed)
        .accessibilityLabel("\(title) account")
        .accessibilityValue(selected?.name ?? "None selected")
    }
}

// MARK: - Small helpers

private struct FieldRow<Content: View>: View {
    let icon: String
    let title: String
    var alignTop = false
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: alignTop ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
                .frame(width: 32, height: 32)
                .background(CustomColor.darkGray.color.opacity(0.06),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.manrope, size: 14, weight: .semiBold)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)
            content
        }
        .padding(.vertical, 12)
    }
}

private struct TransactionBreakdownRow: View {
    let title: String
    let value: String
    var emphasized = false

    var body: some View {
        HStack {
            Text(title)
                .font(.manrope, size: 14, weight: emphasized ? .bold : .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(emphasized ? 1 : 0.6))
            Spacer()
            Text(value)
                .font(.manrope, size: 14, weight: emphasized ? .extraBold : .semiBold)
                .foregroundStyle(CustomColor.darkGray.color)
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    TransferFormView(form: TransferFormViewModel(
        accounts: InMemoryAccountRepository().fetchAccounts(),
        onSave: { _ in }
    ))
}
