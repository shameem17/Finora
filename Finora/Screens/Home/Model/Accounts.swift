//
//  Accounts.swift
//  Finora
//
//  Created by Shameem on 11/11/26.
//

import Foundation

struct Account: Identifiable, Hashable {
    let id: UUID
    var name: String
    var number: String
    var type: AccountType
    /// Optional bundled asset name (kept for built-in providers).
    var logo: String?
    /// User-picked logo, stored as a small PNG.
    var logoData: Data?
    /// Hex colour, e.g. `#007366`.
    var tint: String
    /// What the account held when it was added. Editable.
    var initialBalance: Double

    /// Net effect of everything recorded against this account since it was added
    /// (transfers, loans, repayments…). Only the repository writes it.
    private(set) var netMovement: Double

    /// Calculated, never edited directly: initial balance + all recorded movement.
    var balance: Double { initialBalance + netMovement }

    /// Convenience used by seed data: `balance` becomes the initial balance.
    init(id: UUID = UUID(),
         name: String,
         number: String,
         type: AccountType,
         balance: Double,
         logo: String? = nil,
         tint: String,
         logoData: Data? = nil) {
        self.id = id
        self.name = name
        self.number = number
        self.type = type
        self.logo = logo
        self.logoData = logoData
        self.tint = tint
        self.initialBalance = balance
        self.netMovement = 0
    }

    /// Records a balance change (negative to debit).
    mutating func recordMovement(_ delta: Double) {
        netMovement += delta
    }

    /// Returns a copy of `self` that keeps `other`'s recorded movement, so
    /// editing an account's details never loses its history.
    func keepingMovement(of other: Account) -> Account {
        var copy = self
        copy.netMovement = other.netMovement
        return copy
    }
}
