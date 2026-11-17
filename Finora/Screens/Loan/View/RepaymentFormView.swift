//
//  RepaymentFormView.swift
//  Finora
//
//  Screens/Loan/View
//

import SwiftUI

struct RepaymentFormView: View {

    @Bindable var form: RepaymentFormViewModel

    private var kind: LoanKind { form.kind }

    var body: some View {
        FormSheet(title: kind.repaymentActionTitle,
                  primaryTitle: kind.repaymentActionTitle,
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            headerCard

            AmountField(title: "Amount", text: $form.amountText) {
                HStack(spacing: 8) {
                    AmountChip(title: "Full amount · \(CurrencyFormatter.taka(form.outstanding, showFraction: true))",
                               tint: kind.tint.color) {
                        Keyboard.dismiss()
                        form.payInFull()
                    }

                    if let next = form.nextInstallment {
                        AmountChip(title: "Next installment · \(CurrencyFormatter.taka(next.remaining, showFraction: true))",
                                   tint: kind.tint.color) {
                            Keyboard.dismiss()
                            form.payNextInstallment()
                        }
                    }
                }
            }

            accountCard
            detailsCard
            breakdown
            FormErrorBanner(message: form.visibleError)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            PersonAvatar(person: form.item.person, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(form.item.person.name)
                    .font(.manrope, size: 16, weight: .bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("\(kind.outstandingCaption): \(CurrencyFormatter.taka(form.outstanding, showFraction: true))")
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
                    .tint(Color.accent)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField("e.g. Cash handed over", text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .formFieldStyle()
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
