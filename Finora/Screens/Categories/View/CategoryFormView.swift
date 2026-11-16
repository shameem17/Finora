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
    @FocusState private var focused: Field?
    @State private var confirmDelete = false

    private enum Field: Hashable { case name, budget }

    private let iconColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        CategoryRow(category: form.draft)
                            .accessibilityHidden(true)

                        nameCard
                        iconCard
                        colorCard
                        if form.supportsBudget { budgetCard }
                        FormErrorBanner(message: form.error)

                        if form.isEditing {
                            Button(role: .destructive) { confirmDelete = true } label: {
                                Text("Delete Category")
                                    .font(.manrope, size: 15, weight: .bold)
                                    .foregroundStyle(CustomColor.dangerRed.color)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: form.error)
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
                FormPrimaryButton(title: form.isEditing ? "Save Changes" : "Save Category",
                                  isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
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
        .presentationDragIndicator(.visible)
    }

    private var nameCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "textformat", title: "Name") {
                TextField("e.g. Groceries", text: $form.name)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($focused, equals: .name)
                    .onSubmit { focused = nil }
                    .onChange(of: form.name) { _, _ in form.clearError() }
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    private var iconCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            label("ICON")
            LazyVGrid(columns: iconColumns, spacing: 10) {
                ForEach(form.kind.icons, id: \.self) { symbol in
                    let selected = symbol == form.icon
                    Button { form.icon = symbol } label: {
                        Image(systemName: symbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selected ? Color.white : CustomColor.darkGray.color.opacity(0.7))
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(selected ? Color(hex: form.tintHex) : CustomColor.darkGray.color.opacity(0.06),
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(symbol)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    private var colorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            label("COLOUR")
            ColorSwatchPicker(hex: $form.tintHex)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("MONTHLY BUDGET (OPTIONAL)")
            HStack(spacing: 6) {
                Text("৳")
                    .font(.manrope, size: 30, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
                TextField("0", text: $form.budgetText)
                    .font(.manrope, size: 34, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .keyboardType(.decimalPad)
                    .focused($focused, equals: .budget)
                    .minimumScaleFactor(0.5)
                    .onChange(of: form.budgetText) { _, new in
                        let clean = DecimalInput.sanitize(new)
                        if clean != new { form.budgetText = clean }
                    }
            }
            Text("Leave empty if you don't want a spending limit for this category.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .budget }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.manrope, size: 12, weight: .semiBold)
            .tracking(1)
            .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
    }
}

#Preview {
    CategoryFormView(form: CategoryFormViewModel(mode: .create(kind: .expense),
                                                 repository: InMemoryCategoryRepository()))
}
