//
//  AccountFormViewModel.swift
//  Finora
//
//  Screens/Accounts/ViewModel
//

import Foundation
import Observation

@Observable
final class AccountFormViewModel: Identifiable, LogoEditing {

    enum Mode {
        case create
        case edit(Account)
    }

    let id = UUID()
    let mode: Mode

    var name = ""
    var number = ""
    var type: AccountType = .bank
    var tintHex = Palette.accentHex
    var initialBalanceText = ""

    var logoData: Data?
    var isProcessingLogo = false

    /// Bundled asset logo carried over from an existing account.
    private var logoAsset: String?
    private let repository: AccountRepositoryProtocol
    private let previewID = UUID()

    init(mode: Mode, repository: AccountRepositoryProtocol) {
        self.mode = mode
        self.repository = repository

        if case .edit(let account) = mode {
            name = account.name
            number = account.number
            type = account.type
            tintHex = account.tint
            logoData = account.logoData
            logoAsset = account.logo
            initialBalanceText = DecimalInput.text(account.initialBalance)
        }
    }

    // MARK: Derived

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { isEditing ? "Edit Account" : "New Account" }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var initialBalance: Double { DecimalInput.value(of: initialBalanceText) }

    /// Movement recorded since the account was added (transfers, loans…). Read-only.
    private var movement: Double {
        guard case .edit(let account) = mode else { return 0 }
        return (repository.account(id: account.id) ?? account).netMovement
    }

    /// What the balance will be once saved: initial balance + recorded movement.
    var currentBalance: Double { initialBalance + movement }

    var hasLogo: Bool { logoData != nil || logoAsset != nil }
    var canSubmit: Bool { !trimmedName.isEmpty && !isProcessingLogo }

    /// Live preview shown at the top of the form.
    var draft: Account {
        var account = Account(id: editingID ?? previewID,
                              name: trimmedName.isEmpty ? "Account name" : trimmedName,
                              number: number,
                              type: type,
                              balance: initialBalance,
                              logo: logoAsset,
                              tint: tintHex,
                              logoData: logoData)
        account.recordMovement(movement)
        return account
    }

    private var editingID: Account.ID? {
        if case .edit(let account) = mode { return account.id }
        return nil
    }

    // MARK: Intents

    func removeLogo() {
        logoData = nil
        logoAsset = nil
    }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit else { return false }

        let trimmedNumber = number.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            repository.add(Account(name: trimmedName,
                                   number: trimmedNumber,
                                   type: type,
                                   balance: initialBalance,
                                   logo: nil,
                                   tint: tintHex,
                                   logoData: logoData))

        case .edit(var account):
            account.name = trimmedName
            account.number = trimmedNumber
            account.type = type
            account.tint = tintHex
            account.logo = logoAsset
            account.logoData = logoData
            account.initialBalance = initialBalance
            repository.update(account)
        }
        return true
    }
}
