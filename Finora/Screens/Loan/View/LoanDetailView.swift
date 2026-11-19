//
//  LoanDetailView.swift
//  Finora
//
//  Screens/Loan/View
//
//  Pushed by LoanCoordinator, so no NavigationStack of its own.
//

import SwiftUI

struct LoanDetailView<ViewModel: LoanDetailViewModelProtocol>: View {

    let model: ViewModel

    @State private var repaymentForm: RepaymentFormViewModel?
    @State private var editForm: LoanFormViewModel?
    @State private var confirmDeleteLoan = false
    @State private var repaymentToDelete: Repayment?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if let item = model.item {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header(item)
                        terms(item)
                        if model.installments.count > 1 {
                            schedule
                        }
                        history(item)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: item)
                }
            }
        }
        .navigationTitle(model.item?.person.name ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.item != nil {
                ToolbarItem(placement: .topBarTrailing) { menu }
            }
        }
        .safeAreaInset(edge: .bottom) { bottomAction }
        .task { model.load() }
        .sheet(item: $repaymentForm) { RepaymentFormView(form: $0) }
        .sheet(item: $editForm) { LoanFormView(form: $0) }
        .confirmationDialog("Delete this entry?",
                            isPresented: $confirmDeleteLoan,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { model.deleteLoan() }
        } message: {
            Text("All of its payments are removed too, and your account balances go back to how they were before it.")
        }
        .confirmationDialog("Delete this payment?",
                            isPresented: Binding(get: { repaymentToDelete != nil },
                                                 set: { if !$0 { repaymentToDelete = nil } }),
                            titleVisibility: .visible,
                            presenting: repaymentToDelete) { repayment in
            Button("Delete", role: .destructive) { model.deleteRepayment(id: repayment.id) }
        } message: { repayment in
            Text("\(CurrencyFormatter.taka(repayment.amount, showFraction: true)) will go back to the \(repayment.account.name) balance adjustment.")
        }
    }

    // MARK: - Toolbar / bottom

    private var menu: some View {
        Menu {
            Button {
                editForm = model.makeEditFormViewModel()
            } label: {
                Label("Edit details", systemImage: "pencil")
            }

            Button(role: .destructive) {
                confirmDeleteLoan = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .accessibilityLabel("More")
    }

    @ViewBuilder
    private var bottomAction: some View {
        if let item = model.item, !item.loan.isSettled {
            AddActionButton(title: item.loan.kind.repaymentActionTitle) {
                repaymentForm = model.makeRepaymentFormViewModel()
            }
        }
    }

    // MARK: - Header

    private func header(_ item: LoanItem) -> some View {
        let loan = item.loan
        let person = item.person

        return VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                PersonAvatar(person: person, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.manrope, size: 18, weight: .extraBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("\(loan.kind.personRole) · \(person.category.title)")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer(minLength: 8)

                if let label = item.status.label {
                    StatusChip(text: label, color: item.status.color)
                }
            }

            contactLines(person)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text((loan.isSettled ? "Fully settled" : loan.kind.outstandingCaption).uppercased())
                    .font(.manrope, size: 12, weight: .semiBold)
                    .tracking(1)
                    .foregroundStyle(Color.textSecondary)

                Text(CurrencyFormatter.taka(loan.isSettled ? loan.totalPayable : loan.outstanding,
                                            showFraction: true))
                    .font(.manrope, size: 40, weight: .extraBold)
                    .foregroundStyle(loan.isSettled
                                     ? Color.positive
                                     : Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }

            VStack(spacing: 8) {
                ProgressBar(fraction: loan.progress, color: loan.kind.tint.color)

                HStack {
                    Text("\(loan.kind == .lent ? "Received" : "Paid") \(CurrencyFormatter.taka(loan.totalRepaid, showFraction: true)) of \(CurrencyFormatter.taka(loan.totalPayable, showFraction: true))")
                        .font(.manrope, size: 12, weight: .medium)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 8)

                    Text("\(Int((loan.progress * 100).rounded()))%")
                        .font(.manrope, size: 12, weight: .bold)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    @ViewBuilder
    private func contactLines(_ person: Person) -> some View {
        let phone = person.phone ?? ""
        let address = person.address ?? ""

        if !phone.isEmpty || !address.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !phone.isEmpty {
                    if let url = URL(string: "tel:" + phone.filter { $0.isNumber || $0 == "+" }) {
                        Link(destination: url) {
                            Label(phone, systemImage: "phone.fill")
                        }
                    } else {
                        Label(phone, systemImage: "phone.fill")
                    }
                }
                if !address.isEmpty {
                    Label(address, systemImage: "mappin.and.ellipse")
                }
            }
            .font(.manrope, size: 13, weight: .semiBold)
            .foregroundStyle(Color.textSecondary)
            .labelStyle(.titleAndIcon)
        }
    }

    // MARK: - Terms

    private func terms(_ item: LoanItem) -> some View {
        let loan = item.loan

        return VStack(spacing: 12) {
            ValueRow(title: "Type", value: loan.kind.typeDescription)
            ValueRow(title: loan.kind.accountFieldTitle, value: loan.account.name)
            ValueRow(title: "Date", value: loan.date.shortDisplay)

            Divider()

            ValueRow(title: "Amount", value: CurrencyFormatter.taka(loan.principal, showFraction: true))
            if loan.interest > 0 {
                ValueRow(title: "Interest / extra",
                         value: CurrencyFormatter.taka(loan.interest, showFraction: true))
                ValueRow(title: "Total",
                         value: CurrencyFormatter.taka(loan.totalPayable, showFraction: true),
                         emphasized: true)
            }

            if let due = loan.dueDate {
                Divider()
                ValueRow(title: loan.installmentCount > 1 ? "First due" : "Due",
                         value: due.shortDisplay)
                if loan.installmentCount > 1 {
                    ValueRow(title: "Plan", value: "\(loan.installmentCount) monthly installments")
                }
            } else {
                Divider()
                ValueRow(title: "Due", value: "No due date")
            }

            if let note = loan.note, !note.isEmpty {
                Divider()
                ValueRow(title: "Note", value: note)
            }
        }
        .padding(16)
        .finoraCard(cornerRadius: 24)
    }

    // MARK: - Installments

    private var schedule: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Installments")

            VStack(spacing: 0) {
                ForEach(model.installments) { installment in
                    InstallmentRow(installment: installment)
                    if installment.id != model.installments.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .finoraCard(cornerRadius: 24)
        }
    }

    // MARK: - Payments

    private func history(_ item: LoanItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(item.loan.kind.repaymentsHeading)

            if model.repayments.isEmpty {
                Text("Nothing recorded yet.")
                    .font(.manrope, size: 14, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .finoraCard(cornerRadius: 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(model.repayments) { repayment in
                        RepaymentRow(repayment: repayment) {
                            repaymentToDelete = repayment
                        }
                        if repayment.id != model.repayments.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .finoraCard(cornerRadius: 24)
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.manrope, size: 16, weight: .bold)
            .foregroundStyle(Color.textSecondary)
            .padding(.leading, 4)
    }
}

// MARK: - Rows

private struct InstallmentRow: View {
    let installment: Installment

    private var isOverdue: Bool {
        !installment.isPaid && installment.dueDate < Calendar.current.startOfDay(for: .now)
    }

    private var icon: String {
        if installment.isPaid { return "checkmark.circle.fill" }
        return isOverdue ? "exclamationmark.circle.fill" : "circle"
    }

    private var color: Color {
        if installment.isPaid { return Color.positive }
        return isOverdue ? Color.negative : Color.textTertiary
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text("Installment \(installment.number)")
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)

                Text(installment.dueDate.shortDisplay)
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(isOverdue ? Color.negative
                                               : Color.textSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(CurrencyFormatter.taka(installment.amount, showFraction: true))
                    .font(.manrope, size: 15, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary.opacity(installment.isPaid ? 0.5 : 1))

                if !installment.isPaid, installment.paid > 0 {
                    Text("\(CurrencyFormatter.taka(installment.paid, showFraction: true)) paid")
                        .font(.manrope, size: 11, weight: .semiBold)
                        .foregroundStyle(Color.positive)
                }
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

private struct RepaymentRow: View {
    let repayment: Repayment
    let onDelete: () -> Void

    private var subtitle: String {
        var parts = [repayment.account.name]
        if let note = repayment.note, !note.isEmpty { parts.append(note) }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 14) {
            AccountBadge(type: repayment.account.type, tint: repayment.account.tint, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(repayment.date.shortDisplay)
                    .font(.manrope, size: 15, weight: .bold)
                    .foregroundStyle(Color.textPrimary)

                Text(subtitle)
                    .font(.manrope, size: 12, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 8)

            Text(CurrencyFormatter.taka(repayment.amount, showFraction: true))
                .font(.manrope, size: 15, weight: .extraBold)
                .foregroundStyle(Color.textPrimary)

            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete payment", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.textTertiary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Payment options")
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    let dependencies = LoanDependencies.preview()
    if let loan = dependencies.loans.fetchLoans().first(where: { $0.installmentCount > 1 }) {
        NavigationStack {
            LoanDetailView(model: LoanDetailViewModel(loanID: loan.id, dependencies: dependencies))
        }
    }
}
