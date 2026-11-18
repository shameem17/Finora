//
//  CashFlowFormView.swift
//  Finora
//
//  Screens/CashFlow/View
//

import SwiftUI

struct CashFlowFormView: View {

    @Bindable var form: CashFlowFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false

    private var kind: CategoryKind { form.kind }
    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 10)]

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.saveTitle,
                  tint: kind.tint,
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            AmountField(title: "Amount", text: $form.amountText)
            categoryCard

            AccountDropdown(title: kind.accountTitle,
                            accounts: form.accounts,
                            selection: $form.accountID,
                            excluded: nil)
                .padding(16)
                .finoraCard()

            detailsCard
            breakdown
            FormErrorBanner(message: form.visibleError)
            if form.isEditing { deleteButton }
        }
    }

    // MARK: - Category

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Category")

            if form.hasCategories {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(form.categories) { category in
                        categoryChip(category)
                    }
                }
            } else {
                Text("You don't have any \(kind.singular) categories yet. Add one from the Categories tab first.")
                    .font(.manrope, size: 13, weight: .medium)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .sectionCard()
    }

    private func categoryChip(_ category: TransactionCategory) -> some View {
        let selected = category.id == form.categoryID
        let tint = Color(hex: category.tint)

        return Button { form.categoryID = category.id } label: {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selected ? Color.white : tint)
                    .frame(width: 40, height: 40)
                    .background(selected ? tint : tint.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(category.name)
                    .font(.manrope, size: 11, weight: selected ? .bold : .semiBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(selected ? tint.opacity(0.12) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "calendar", title: "Date") {
                DatePicker("Date", selection: $form.date,
                           in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.accent)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note (optional)", alignTop: true) {
                TextField(kind == .income ? "e.g. November salary" : "e.g. Lunch with team",
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
        if let after = form.balanceAfter, let account = form.account {
            ValueRow(title: "\(account.name) balance after",
                     value: CurrencyFormatter.taka(after, showFraction: true),
                     emphasized: true)
                .padding(16)
                .finoraCard(cornerRadius: 22)
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { confirmDelete = true } label: {
            Text("Delete \(kind.title)")
                .font(.manrope, size: 15, weight: .bold)
                .foregroundStyle(Color.negative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .confirmationDialog("Delete this \(kind.singular)?",
                            isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                form.delete()
                dismiss()
            }
        } message: {
            Text("The account balance is adjusted back.")
        }
    }
}

#Preview {
    CashFlowFormView(form: CashFlowFormViewModel(mode: .create(kind: .expense),
                                                 dependencies: .preview()))
}
