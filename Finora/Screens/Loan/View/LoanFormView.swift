//
//  LoanFormView.swift
//  Finora
//
//  Screens/Loan/View
//

import SwiftUI

struct LoanFormView: View {

    @Bindable var form: LoanFormViewModel
    @State private var showPersonPicker = false

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.saveTitle,
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            if !form.isEditing {
                PillPicker(selection: $form.kind)
            }
            partyCard
                .sheet(isPresented: $showPersonPicker) { PersonPickerView(form: form) }
            amountCard
            detailsCard
            breakdown
            FormErrorBanner(message: form.visibleError)
        }
    }

    // MARK: - Person + account

    private var partyCard: some View {
        VStack(spacing: 0) {
            Button {
                Keyboard.dismiss()
                showPersonPicker = true
            } label: {
                personRow
            }
            .buttonStyle(.plain)

            Divider().padding(.vertical, 8)

            if let locked = form.lockedAccount {
                lockedAccountRow(locked)
            } else {
                AccountDropdown(title: form.kind.accountFieldTitle,
                                accounts: form.accounts,
                                selection: $form.accountID,
                                excluded: nil)
            }
        }
        .padding(16)
        .finoraCard()
    }

    private var personRow: some View {
        HStack(spacing: 14) {
            if let person = form.person {
                PersonAvatar(person: person, size: 44)
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textTertiary)
                    .frame(width: 44, height: 44)
                    .background(Color.fillSubtle, in: Circle())
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(form.kind.personRole.uppercased())
                    .font(.manrope, size: 11, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(Color.textSecondary)

                Text(form.person?.name ?? "Select \(form.kind.personRole.lowercased())")
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                if let person = form.person {
                    Text(person.phone ?? person.category.title)
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(form.kind.personRole)
        .accessibilityValue(form.person?.name ?? "None selected")
    }

    private func lockedAccountRow(_ account: AccountSummary) -> some View {
        HStack(spacing: 14) {
            AccountBadge(type: account.type, tint: account.tint, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(form.kind.accountFieldTitle.uppercased())
                    .font(.manrope, size: 11, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(Color.textSecondary)

                Text(account.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Amount

    @ViewBuilder
    private var amountCard: some View {
        if form.isEditing {
            lockedAmountCard
        } else {
            AmountField(title: "Amount", text: $form.amountText)
        }
    }

    private var lockedAmountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionLabel("Amount")
                Spacer()
                Label("Locked", systemImage: "lock.fill")
                    .font(.manrope, size: 11, weight: .bold)
                    .foregroundStyle(Color.textTertiary)
            }

            Text(CurrencyFormatter.taka(form.amount, showFraction: true))
                .font(.manrope, size: 40, weight: .extraBold)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text("To change the amount or account, delete this entry and add it again.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
        .sectionCard()
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "percent", title: "Interest / extra charge") {
                HStack(spacing: 4) {
                    Text(CurrencyFormatter.symbol).foregroundStyle(Color.textTertiary)
                    TextField("0", text: $form.interestText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                        .onChange(of: form.interestText) { _, new in
                            let clean = DecimalInput.sanitize(new)
                            if clean != new { form.interestText = clean }
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
                    .tint(Color.accent)
                    .onChange(of: form.date) { _, _ in form.loanDateChanged() }
            }

            Divider()

            FormFieldRow(icon: "calendar.badge.clock", title: "Set a due date") {
                Toggle("Set a due date", isOn: $form.hasDueDate.animation(.smooth))
                    .labelsHidden()
                    .tint(CustomColor.vividTeal.color)
            }

            if form.hasDueDate {
                Divider()

                FormFieldRow(icon: "flag.fill", title: form.installmentCount > 1 ? "First due date" : "Due date") {
                    DatePicker("Due date",
                               selection: $form.dueDate,
                               in: form.date...,
                               displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.accent)
                }

                Divider()

                FormFieldRow(icon: "list.number", title: "Monthly installments") {
                    Stepper(value: $form.installmentCount, in: 1...Loan.maxInstallments) {
                        Text("\(form.installmentCount)")
                            .font(.manrope, size: 16, weight: .bold)
                            .foregroundStyle(Color.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: 150)
                }
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField("e.g. Rent, shop stock…", text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    // MARK: - Breakdown

    @ViewBuilder
    private var breakdown: some View {
        if form.amount > 0 {
            VStack(spacing: 10) {
                ValueRow(title: "Amount",
                         value: CurrencyFormatter.taka(form.amount, showFraction: true))

                if form.interest > 0 {
                    ValueRow(title: "Interest / extra",
                             value: CurrencyFormatter.taka(form.interest, showFraction: true))
                }

                Divider()

                ValueRow(title: form.kind == .lent ? "Total to receive" : "Total to pay",
                         value: CurrencyFormatter.taka(form.totalPayable, showFraction: true),
                         emphasized: true)

                if let each = form.installmentAmount {
                    ValueRow(title: "\(form.installmentCount) monthly installments of",
                             value: "≈ " + CurrencyFormatter.taka(each, showFraction: true))
                }

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

#Preview("New") {
    LoanFormView(form: LoanFormViewModel(mode: .create(kind: .borrowed),
                                         dependencies: .preview()))
}
