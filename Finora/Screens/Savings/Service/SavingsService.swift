//
//  SavingsService.swift
//  Finora
//
//  Screens/Savings/Service
//

import Foundation

/// Every write goes through here so account balances and savings records
/// can never drift apart.
protocol SavingsServiceProtocol: AnyObject {
    func create(_ savings: SavingsAccount)
    /// Saves edited details. Entries and the opening balance are never touched.
    func update(_ savings: SavingsAccount)
    /// Removes the savings account. With `returnRemaining`, what is left is credited to its tagged account.
    func delete(savingsID: SavingsAccount.ID, returnRemaining: Bool)
    /// Moves `entry.amount` from `entry.account` into the savings account.
    func deposit(_ entry: SavingsEntry, to savingsID: SavingsAccount.ID)
    /// Moves `entry.amount` out of the savings account into `entry.account`.
    func withdraw(_ entry: SavingsEntry, from savingsID: SavingsAccount.ID)
    /// Reverses one entry. Returns `false` when removing it would leave the savings negative.
    @discardableResult
    func deleteEntry(id: SavingsEntry.ID, from savingsID: SavingsAccount.ID) -> Bool
}

final class SavingsService: SavingsServiceProtocol {

    private let savings: SavingsRepositoryProtocol
    private let accounts: AccountRepositoryProtocol

    init(savings: SavingsRepositoryProtocol, accounts: AccountRepositoryProtocol) {
        self.savings = savings
        self.accounts = accounts
    }

    func create(_ item: SavingsAccount) {
        savings.add(item)
    }

    func update(_ item: SavingsAccount) {
        guard var stored = savings.savings(id: item.id) else { return }
        stored.name = item.name
        stored.number = item.number
        stored.accountID = item.accountID
        stored.logoData = item.logoData
        stored.tint = item.tint
        stored.startDate = item.startDate
        stored.target = item.target
        stored.targetDate = item.targetDate
        stored.note = item.note
        savings.update(stored)
    }

    func delete(savingsID: SavingsAccount.ID, returnRemaining: Bool) {
        guard let item = savings.savings(id: savingsID) else { return }
        if returnRemaining, item.currentSavings > 0 {
            accounts.adjustBalance(of: item.accountID, by: item.currentSavings)
        }
        savings.delete(id: savingsID)
    }

    func deposit(_ entry: SavingsEntry, to savingsID: SavingsAccount.ID) {
        guard var item = savings.savings(id: savingsID) else { return }
        accounts.adjustBalance(of: entry.account.id, by: -entry.amount)
        item.entries.append(entry)
        savings.update(item)
    }

    func withdraw(_ entry: SavingsEntry, from savingsID: SavingsAccount.ID) {
        guard var item = savings.savings(id: savingsID),
              entry.amount <= item.currentSavings + 0.005 else { return }
        accounts.adjustBalance(of: entry.account.id, by: entry.amount)
        item.entries.append(entry)
        savings.update(item)
    }

    @discardableResult
    func deleteEntry(id: SavingsEntry.ID, from savingsID: SavingsAccount.ID) -> Bool {
        guard var item = savings.savings(id: savingsID),
              let entry = item.entries.first(where: { $0.id == id }) else { return false }

        item.entries.removeAll { $0.id == id }
        // Removing a deposit must not leave more withdrawn than ever saved.
        guard item.totalDeposited - item.totalWithdrawn > -0.005 else { return false }

        let delta = entry.kind == .deposit ? entry.amount : -entry.amount
        accounts.adjustBalance(of: entry.account.id, by: delta)
        savings.update(item)
        return true
    }
}
