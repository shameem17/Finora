//
//  FormKit.swift
//  Finora
//
//  ReusableViews
//
//  The pieces every add / edit form is made of, so all forms look and behave
//  alike: sheet scaffold, amount entry, logo + colour picker.
//

import SwiftUI
import PhotosUI

enum Keyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Sheet scaffold

/// Standard form sheet: own navigation bar with Cancel, scrolling content on the
/// app background, a keyboard "Done" button and the primary button pinned to the bottom.
/// `onSubmit` returns whether the form was saved; the sheet closes when it does.
struct FormSheet<Content: View>: View {
    let title: String
    let primaryTitle: String
    var tint: CustomColor = .accent
    var isEnabled = true
    let onSubmit: () -> Bool
    @ViewBuilder let content: Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.screenBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) { content }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.manrope, size: 16, weight: .semiBold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { Keyboard.dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                FormPrimaryButton(title: primaryTitle, tint: tint, isEnabled: isEnabled) {
                    Keyboard.dismiss()
                    if onSubmit() { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Amount entry

/// Big "৳ 0" entry card. Tapping anywhere on the card focuses the field.
struct AmountField<Accessory: View>: View {
    let title: String
    @Binding var text: String
    var fontSize: CGFloat = 40
    @ViewBuilder let accessory: Accessory

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title)

            HStack(spacing: 6) {
                Text(CurrencyFormatter.symbol)
                    .font(.manrope, size: fontSize - 4, weight: .extraBold)
                    .foregroundStyle(Color.textTertiary)

                TextField("0", text: $text)
                    .font(.manrope, size: fontSize, weight: .extraBold)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .minimumScaleFactor(0.5)
                    .onChange(of: text) { _, new in
                        let clean = DecimalInput.sanitize(new)
                        if clean != new { text = clean }
                    }
            }

            accessory
        }
        .sectionCard()
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }
}

extension AmountField where Accessory == EmptyView {
    init(title: String, text: Binding<String>, fontSize: CGFloat = 40) {
        self.init(title: title, text: text, fontSize: fontSize) { EmptyView() }
    }
}

/// Pill-shaped quick-fill button used under amount fields ("Full amount · ৳5,000").
struct AmountChip: View {
    let title: String
    var tint: Color = Color.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.manrope, size: 12, weight: .bold)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(tint.opacity(0.18), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Logo + colour

/// Anything that can carry a user-picked logo image. Gives forms
/// `setLogo(fromImageData:)` for free.
protocol LogoEditing: AnyObject {
    var logoData: Data? { get set }
    var isProcessingLogo: Bool { get set }
}

extension LogoEditing {
    func setLogo(fromImageData data: Data) async {
        isProcessingLogo = true
        defer { isProcessingLogo = false }
        if let processed = await LogoImageProcessor.makeLogo(from: data) {
            logoData = processed
        }
    }
}

/// "Choose logo" photo picker plus the colour swatches, in one card.
struct LogoColorPickerCard: View {
    @Binding var tintHex: String
    let hasLogo: Bool
    let isProcessing: Bool
    let onPickImage: (Data) async -> Void
    let onRemove: () -> Void

    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Logo")

            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    pill(hasLogo ? "Change logo" : "Choose logo", systemImage: "photo",
                         foreground: .textPrimary, background: .fillSubtle)
                }

                if hasLogo {
                    Button(role: .destructive, action: onRemove) {
                        pill("Remove", systemImage: nil,
                             foreground: .negative, background: Color.negative.opacity(0.1))
                    }
                }

                if isProcessing { ProgressView() }
                Spacer(minLength: 0)
            }

            Divider()

            SectionLabel("Colour")
            ColorSwatchPicker(hex: $tintHex)
        }
        .sectionCard()
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await onPickImage(data)
                }
                photoItem = nil
            }
        }
    }

    @ViewBuilder
    private func pill(_ title: String, systemImage: String?, foreground: Color, background: Color) -> some View {
        Group {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .font(.manrope, size: 14, weight: .bold)
        .foregroundStyle(foreground)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(background, in: Capsule())
    }
}
