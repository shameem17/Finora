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
    /// Moves `entry.amount` into the savings account, debiting `entry.account` when set.
    func deposit(_ entry: SavingsEntry, to savingsID: SavingsAccount.ID)
    /// Moves `entry.amount` out of the savings account, crediting `entry.account` when set.
    func withdraw(_ entry: SavingsEntry, from savingsID: SavingsAccount.ID)
    /// Replaces an entry (same id) and re-applies its account effect. Returns `false` if the result would be invalid.
    @discardableResult
    func updateEntry(_ entry: SavingsEntry, in savingsID: SavingsAccount.ID) -> Bool
    /// Reverses one entry. Returns `false` when removing it would leave the savings negative.
    @discardableResult
    func deleteEntry(id: SavingsEntry.ID, from savingsID: SavingsAccount.ID) -> Bool
}

final class SavingsService: SavingsServiceProtocol {

    private let savings: SavingsRepositoryProtocol
    private let accounts: AccountRepositoryProtocol
    private let unitOfWork: UnitOfWork

    init(savings: SavingsRepositoryProtocol,
         accounts: AccountRepositoryProtocol,
         unitOfWork: UnitOfWork = ImmediateUnitOfWork()) {
        self.savings = savings
        self.accounts = accounts
        self.unitOfWork = unitOfWork
    }

    func create(_ item: SavingsAccount) {
        unitOfWork.perform { savings.add(item) }
    }

    func update(_ item: SavingsAccount) {
        unitOfWork.perform {
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
    }

    func delete(savingsID: SavingsAccount.ID, returnRemaining: Bool) {
        unitOfWork.perform {
            guard let item = savings.savings(id: savingsID) else { return }
            if returnRemaining, item.currentSavings > 0 {
                accounts.adjustBalance(of: item.accountID, by: item.currentSavings)
            }
            savings.delete(id: savingsID)
        }
    }

    func deposit(_ entry: SavingsEntry, to savingsID: SavingsAccount.ID) {
        unitOfWork.perform {
            guard var item = savings.savings(id: savingsID) else { return }
            apply(entry, sign: 1)
            item.entries.append(entry)
            savings.update(item)
        }
    }

    func withdraw(_ entry: SavingsEntry, from savingsID: SavingsAccount.ID) {
        unitOfWork.perform {
            guard var item = savings.savings(id: savingsID),
                  entry.amount <= item.currentSavings + 0.005 else { return }
            apply(entry, sign: 1)
            item.entries.append(entry)
            savings.update(item)
        }
    }

    @discardableResult
    func deleteEntry(id: SavingsEntry.ID, from savingsID: SavingsAccount.ID) -> Bool {
        unitOfWork.perform { () -> Bool in
            guard var item = savings.savings(id: savingsID),
                  let entry = item.entries.first(where: { $0.id == id }) else { return false }

            item.entries.removeAll { $0.id == id }
            // Removing a deposit must not leave more withdrawn than ever saved.
            guard item.totalDeposited - item.totalWithdrawn > -0.005 else { return false }

            apply(entry, sign: -1)
            savings.update(item)
            return true
        }
    }

    @discardableResult
    func updateEntry(_ entry: SavingsEntry, in savingsID: SavingsAccount.ID) -> Bool {
        unitOfWork.perform { () -> Bool in
            guard var item = savings.savings(id: savingsID),
                  let index = item.entries.firstIndex(where: { $0.id == entry.id }) else { return false }

            let old = item.entries[index]
            item.entries[index] = entry
            guard item.totalDeposited - item.totalWithdrawn > -0.005 else { return false }

            apply(old, sign: -1)
            apply(entry, sign: 1)
            savings.update(item)
            return true
        }
    }

    /// Applies (`sign` 1) or reverses (`sign` -1) an entry's effect on its linked account.
    private func apply(_ entry: SavingsEntry, sign: Double) {
        guard let account = entry.account else { return }
        accounts.adjustBalance(of: account.id, by: entry.accountDelta * sign)
    }
}
