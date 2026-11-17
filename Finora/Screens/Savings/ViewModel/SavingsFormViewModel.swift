//
//  SavingsFormViewModel.swift
//  Finora
//
//  Screens/Savings/ViewModel
//

import Foundation
import Observation

@Observable
final class SavingsFormViewModel: Identifiable {

    enum Mode {
        case create
        case edit(SavingsAccount)
    }

    let id = UUID()
    let mode: Mode
    let accounts: [Account]

    var accountID: Account.ID? {
        didSet { if oldValue != accountID { suggestName() } }
    }
    var name = "" {
        didSet { if !isSuggesting { nameEdited = true } }
    }
    var number = ""
    var tintHex = "#00BFA6"
    var startDate: Date = .now
    var targetText = ""
    var hasTargetDate = false
    var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    var openingText = ""
    var note = ""

    private(set) var logoData: Data?
    private(set) var isProcessingLogo = false

    @ObservationIgnored private var nameEdited = false
    @ObservationIgnored private var isSuggesting = false
    @ObservationIgnored private let dependencies: SavingsDependencies

    init(mode: Mode, dependencies: SavingsDependencies) {
        self.mode = mode
        self.dependencies = dependencies
        self.accounts = dependencies.accounts.fetchAccounts()

        switch mode {
        case .create:
            accountID = accounts.first?.id
            if let first = accounts.first { tintHex = first.tint }
            suggestName()
        case .edit(let savings):
            isSuggesting = true
            name = savings.name
            isSuggesting = false
            nameEdited = true
            accountID = savings.accountID
            number = savings.number
            tintHex = savings.tint
            logoData = savings.logoData
            startDate = savings.startDate
            targetText = savings.target.map(Self.text) ?? ""
            if let date = savings.targetDate {
                hasTargetDate = true
                targetDate = date
            }
            note = savings.note
        }
    }

    // MARK: Derived

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { isEditing ? "Edit Savings" : "New Savings" }
    var saveTitle: String { isEditing ? "Save Changes" : "Create Savings Account" }

    var account: Account? { accounts.first { $0.id == accountID } }
    var target: Double? {
        let value = DecimalInput.value(of: targetText)
        return value > 0 ? value : nil
    }
    var openingBalance: Double { DecimalInput.value(of: openingText) }
    var hasLogo: Bool { logoData != nil }

    private var finalName: String { SavingsAccount.suffixed(name) }
    var canSubmit: Bool { accountID != nil && !finalName.isEmpty && !isProcessingLogo }

    var draft: SavingsAccount {
        SavingsAccount(id: editingID ?? UUID(),
                       name: finalName.isEmpty ? "Savings" : finalName,
                       number: number,
                       accountID: accountID ?? UUID(),
                       logoData: logoData,
                       tint: tintHex,
                       startDate: startDate,
                       target: target,
                       openingBalance: isEditing ? 0 : openingBalance)
    }

    private var editingID: SavingsAccount.ID? {
        if case .edit(let savings) = mode { return savings.id }
        return nil
    }

    // MARK: Intents

    func setLogo(fromImageData data: Data) async {
        isProcessingLogo = true
        defer { isProcessingLogo = false }
        if let processed = await LogoImageProcessor.makeLogo(from: data) {
            logoData = processed
        }
    }

    func removeLogo() { logoData = nil }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit, let accountID else { return false }

        let trimmedNumber = number.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let dueDate: Date? = hasTargetDate ? max(targetDate, startDate) : nil

        switch mode {
        case .create:
            dependencies.service.create(
                SavingsAccount(name: finalName, number: trimmedNumber, accountID: accountID,
                               logoData: logoData, tint: tintHex, startDate: startDate,
                               target: target, targetDate: dueDate, note: trimmedNote,
                               openingBalance: openingBalance)
            )
        case .edit(var savings):
            savings.name = finalName
            savings.number = trimmedNumber
            savings.accountID = accountID
            savings.logoData = logoData
            savings.tint = tintHex
            savings.startDate = startDate
            savings.target = target
            savings.targetDate = dueDate
            savings.note = trimmedNote
            dependencies.service.update(savings)
        }
        return true
    }

    // MARK: Private

    private func suggestName() {
        guard !nameEdited, let account else { return }
        isSuggesting = true
        name = SavingsAccount.suffixed(account.name)
        isSuggesting = false
        if !isEditing { tintHex = account.tint }
    }

    private static func text(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
    }
}
