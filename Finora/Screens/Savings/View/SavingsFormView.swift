//
//  SavingsFormView.swift
//  Finora
//
//  Screens/Savings/View
//

import SwiftUI
import PhotosUI

struct SavingsFormView: View {

    @Bindable var form: SavingsFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?
    @State private var photoItem: PhotosPickerItem?

    private enum Field: Hashable { case name, number, target, opening, note }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        SavingsCard(item: SavingsItem(savings: form.draft,
                                                      account: form.account.map(AccountSummary.init)))
                            .accessibilityHidden(true)

                        accountCard
                        detailsCard
                        goalCard
                        if !form.isEditing { openingCard }
                        appearanceCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .animation(.smooth, value: form.hasTargetDate)
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
                FormPrimaryButton(title: form.saveTitle, tint: .vividTeal, isEnabled: form.canSubmit) {
                    focused = nil
                    if form.submit() { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Cards

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AccountDropdown(title: "Tagged account",
                            accounts: form.accounts,
                            selection: $form.accountID,
                            excluded: nil)
            Text("Deposits are taken from, and withdrawals returned to, accounts you choose each time. This one is the default.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
        }
        .padding(16)
        .finoraCard()
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "textformat", title: "Name") {
                TextField("e.g. City Bank Savings", text: $form.name)
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
                    .focused($focused, equals: .number)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
            }

            Divider()

            FormFieldRow(icon: "calendar", title: "Start date") {
                DatePicker("Start date", selection: $form.startDate,
                           in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(CustomColor.vividTeal.color)
            }

            Divider()

            FormFieldRow(icon: "text.alignleft", title: "Note", alignTop: true) {
                TextField("Optional", text: $form.note, axis: .vertical)
                    .lineLimit(1...3)
                    .multilineTextAlignment(.trailing)
                    .focused($focused, equals: .note)
                    .font(.manrope, size: 15, weight: .semiBold)
                    .foregroundStyle(CustomColor.darkGray.color)
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    private var goalCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(icon: "flag.checkered", title: "Target") {
                HStack(spacing: 4) {
                    Text("৳").foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
                    TextField("Optional", text: $form.targetText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focused, equals: .target)
                        .frame(maxWidth: 130)
                        .onChange(of: form.targetText) { _, new in
                            let clean = DecimalInput.sanitize(new)
                            if clean != new { form.targetText = clean }
                        }
                }
                .font(.manrope, size: 16, weight: .bold)
                .foregroundStyle(CustomColor.darkGray.color)
            }

            Divider()

            FormFieldRow(icon: "calendar.badge.clock", title: "Set a target date") {
                Toggle("Set a target date", isOn: $form.hasTargetDate)
                    .labelsHidden()
                    .tint(CustomColor.vividTeal.color)
            }

            if form.hasTargetDate {
                Divider()
                FormFieldRow(icon: "flag.fill", title: "Target date") {
                    DatePicker("Target date", selection: $form.targetDate,
                               in: form.startDate..., displayedComponents: .date)
                        .labelsHidden()
                        .tint(CustomColor.vividTeal.color)
                }
            }
        }
        .padding(.horizontal, 16)
        .finoraCard()
    }

    private var openingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("ALREADY SAVED (OPTIONAL)")
            HStack(spacing: 6) {
                Text("৳")
                    .font(.manrope, size: 30, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color.opacity(0.4))
                TextField("0", text: $form.openingText)
                    .font(.manrope, size: 34, weight: .extraBold)
                    .foregroundStyle(CustomColor.darkGray.color)
                    .keyboardType(.decimalPad)
                    .focused($focused, equals: .opening)
                    .minimumScaleFactor(0.5)
                    .onChange(of: form.openingText) { _, new in
                        let clean = DecimalInput.sanitize(new)
                        if clean != new { form.openingText = clean }
                    }
            }
            Text("Money you've already put aside. It won't be deducted from any account.")
                .font(.manrope, size: 12, weight: .medium)
                .foregroundStyle(CustomColor.darkGray.color.opacity(0.5))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .finoraCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = .opening }
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            label("LOGO")

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
                    Button(role: .destructive) { form.removeLogo() } label: {
                        Text("Remove")
                            .font(.manrope, size: 14, weight: .bold)
                            .foregroundStyle(CustomColor.dangerRed.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(CustomColor.dangerRed.color.opacity(0.1), in: Capsule())
                    }
                }

                if form.isProcessingLogo { ProgressView() }
                Spacer(minLength: 0)
            }

            Divider()

            label("COLOUR")
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

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.manrope, size: 12, weight: .semiBold)
            .tracking(1)
            .foregroundStyle(CustomColor.darkGray.color.opacity(0.55))
    }
}

#Preview {
    SavingsFormView(form: SavingsFormViewModel(mode: .create, dependencies: .preview()))
}
