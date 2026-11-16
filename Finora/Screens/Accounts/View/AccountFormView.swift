//
//  AccountFormView.swift
//  Finora
//
//  Screens/Accounts/View
//

import SwiftUI
import PhotosUI

struct AccountFormView: View {

    @Bindable var form: AccountFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?
    @State private var photoItem: PhotosPickerItem?

    private enum Field: Hashable { case name, number, balance }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        AccountCard(account: form.draft)
                            .shadow(color: Color(hex: form.tintHex).opacity(0.35), radius: 10)
                            .animation(.smooth, value: form.tintHex)
                            .accessibilityHidden(true)

                        detailsCard
                        appearanceCard
                        balanceCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
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
                FormPrimaryButton(title: form.isEditing ? "Save Changes" : "Save Account",
                                  isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "textformat", title: "Name") {
                TextField("e.g. City Bank", text: $form.name)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focused, equals: .name)
                    .onSubmit { focused = .number }
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
            }

            Divider()

            FormFieldRow(icon: "number", title: "Account no.") {
                TextField("Optional", text: $form.number)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($focused, equals: .number)
                    .onSubmit { focused = nil }
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
            }

            Divider()

            FormFieldRow(icon: "square.grid.2x2", title: "Type") {
                Picker("Type", selection: $form.type) {
                    ForEach(AccountType.selectable) { type in
                        Label(type.title, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(CustomColor.darkGray.color)
                .labelsHidden()
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    // MARK: - Logo + colour

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("LOGO")

            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Label(form.hasLogo ? "Change logo" : "Choose logo", systemImage: "photo")
                        .font(.manrope, size: 14, weight: .bold)
                        .foregroundStyle(CustomColor.darkGray.color)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(CustomColor.darkGray.color.opacity(0.06), in: Capsule())
                }

                if form.hasLogo {
                    Button(role: .destructive) {
                        form.removeLogo()
                    } label: {
                        Text("Remove")
                            .font(.manrope, size: 14, weight: .bold)
                            .foregroundStyle(CustomColor.dangerRed.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(CustomColor.dangerRed.color.opacity(0.1), in: Capsule())
                    }
                }

                if form.isProcessingLogo {
                    ProgressView()
                }
                Spacer(minLength: 0)
            }

            Divider()

            sectionLabel("COLOUR")
            ColorSwatchPicker(hex: $form.tintHex)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await form.setLogo(fromImageData: data)
                }
                photoItem = nil
            }
        }
    }

    // MARK: - Balance

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("INITIAL BALANCE")

            HStack(spacing: 6) {
                Text("৳")
                    .font(.manrope, size: 30, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))

                TextField("0", text: $form.initialBalanceText)
                    .font(.manrope, size: 34, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .keyboardType(.decimalPad)
                    .focused($focused, equals: .balance)
                    .minimumScaleFactor(0.5)
                    .onChange(of: form.initialBalanceText) { _, new in
                        let clean = DecimalInput.sanitize(new)
                        if clean != new { form.initialBalanceText = clean }
                    }
            }

            Divider()

            HStack {
                Label("Current balance", systemImage: "lock.fill")
                    .font(.manrope, size: 14, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.6))

                Spacer(minLength: 8)

                Text(CurrencyFormatter.taka(form.currentBalance, showFraction: true))
                    .font(.manrope, size: 16, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .contentTransition(.numericText())
            }

            Text(form.isEditing
                 ? "Calculated from your initial balance plus every transfer, loan and payment. It can't be edited directly."
                 : "Starts equal to the initial balance, then updates automatically as you record activity.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .balance }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.manrope, size: 12, weight: .semiBold)
            .tracking(1)
            .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
    }
}

#Preview {
    AccountFormView(form: AccountFormViewModel(mode: .create, repository: InMemoryAccountRepository()))
}
