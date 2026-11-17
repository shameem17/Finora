//
//  CategoryFormView.swift
//  Finora
//
//  Screens/Categories/View
//

import SwiftUI

struct CategoryFormView: View {

    @Bindable var form: CategoryFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false

    private let iconColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        FormSheet(title: form.title,
                  primaryTitle: form.isEditing ? "Save Changes" : "Save Category",
                  isEnabled: form.canSubmit,
                  onSubmit: form.submit) {
            CategoryRow(category: form.draft)
                .accessibilityHidden(true)

            nameCard
            iconCard
            colorCard
            if form.supportsBudget { budgetCard }
            FormErrorBanner(message: form.error)
            if form.isEditing { deleteButton }
        }
    }

    private var nameCard: some View {
        FormFieldRow(icon: "textformat", title: "Name") {
            TextField("e.g. Groceries", text: $form.name)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.words)
                .formFieldStyle()
                .onChange(of: form.name) { _, _ in form.clearError() }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    private var iconCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Icon")

            LazyVGrid(columns: iconColumns, spacing: 10) {
                ForEach(form.kind.icons, id: \.self) { symbol in
                    let selected = symbol == form.icon
                    Button { form.icon = symbol } label: {
                        Image(systemName: symbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selected ? Color.white : Color.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(selected ? Color(hex: form.tintHex) : Color.fillSubtle,
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(symbol)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
        .sectionCard()
    }

    private var colorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Colour")
            ColorSwatchPicker(hex: $form.tintHex)
        }
        .sectionCard()
    }

    private var budgetCard: some View {
        AmountField(title: "Monthly budget (optional)", text: $form.budgetText, fontSize: 34) {
            Text("Leave empty if you don't want a spending limit for this category.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { confirmDelete = true } label: {
            Text("Delete Category")
                .font(.manrope, size: 15, weight: .bold)
                .foregroundStyle(Color.negative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .confirmationDialog("Delete this category?",
                            isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                form.delete()
                dismiss()
            }
        } message: {
            Text("Existing transactions are not removed.")
        }
    }
}

#Preview {
    CategoryFormView(form: CategoryFormViewModel(mode: .create(kind: .expense),
                                                 repository: InMemoryCategoryRepository()))
}
