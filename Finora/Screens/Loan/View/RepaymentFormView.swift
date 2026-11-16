//
//  RepaymentFormView.swift
//  Finora
//
//  Screens/Loan/View
//

import SwiftUI

struct RepaymentFormView: View {

    @Bindable var form: RepaymentFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?

    private enum Field: Hashable { case amount, note }

    private var kind: LoanKind { form.kind }

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
            .navigationTitle(kind.repaymentActionTitle)
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
                FormPrimaryButton(title: kind.repaymentActionTitle, isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            PersonAvatar(person: form.item.person, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(form.item.person.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .lineLimit(1)

                Text("\(kind.outstandingCaption): \(CurrencyFormatter.taka(form.outstanding, showFraction: true))")
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

    // MARK: - Amount

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

            HStack(spacing: 8) {
                quickChip("Full amount · \(CurrencyFormatter.taka(form.outstanding, showFraction: true))") {
                    focused = nil
                    form.payInFull()
                }

                if let next = form.nextInstallment {
                    quickChip("Next installment · \(CurrencyFormatter.taka(next.remaining, showFraction: true))") {
                        focused = nil
                        form.payNextInstallment()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .amount }
    }

    private func quickChip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.manrope, size: 12, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(kind.tint.color.opacity(0.18), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Account / details

    private var accountCard: some View {
        AccountDropdown(title: kind.repaymentAccountTitle,
                        accounts: form.accounts,
                        selection: $form.accountID,
                        excluded: nil)
            .padding(16)
            .finoraCard()
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date",
                           selection: $form.date,
                           in: form.earliestDate...Date.now,
                           displayedComponents: .date)
                    .labelsHidden()
                    .tint(CustomColor.warmCoral.color)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField("e.g. Cash handed over", text: $form.note, axis: .vertical)
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

    // MARK: - Breakdown

    @ViewBuilder
    private var breakdown: some View {
        if let remaining = form.remainingAfter {
            VStack(spacing: 10) {
                ValueRow(title: "Amount",
                         value: CurrencyFormatter.taka(form.amount, showFraction: true))

                Divider()

                ValueRow(title: remaining < Loan.tolerance ? "Fully settled" : "Remaining after",
                         value: CurrencyFormatter.taka(remaining, showFraction: true),
                         emphasized: true)

                if let after = form.balanceAfter, let account = form.account {
                    ValueRow(title: "\(account.name) balance after",
                             value: CurrencyFormatter.taka(after, showFraction: true))
                }
            }
            .padding(16)
            .finoraCard(cornerRadius: 22)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

#Preview {
    let dependencies = LoanDependencies.preview()
    if let loan = dependencies.loans.fetchLoans().first(where: { $0.kind == .borrowed && !$0.isSettled }) {
        RepaymentFormView(
            form: RepaymentFormViewModel(
                item: LoanItem(loan: loan, person: dependencies.people.person(id: loan.personID)),
                dependencies: dependencies
            )
        )
    }
}
