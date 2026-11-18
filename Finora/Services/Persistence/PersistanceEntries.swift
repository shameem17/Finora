//
//  PersistanceEntry.swift
//  Finora
//
//  Created by Shameem on 11/18/26.
//


import Foundation
import SwiftData

// MARK: - Stable storage keys

/// Persists an enum by its case name instead of its display `rawValue`, so
/// changing a title in the UI can never orphan stored data. Don't rename cases.
protocol StorageKeyed: CaseIterable {}

extension StorageKeyed {
    var storageKey: String { String(describing: self) }

    init?(storageKey: String) {
        guard let match = Self.allCases.first(where: { $0.storageKey == storageKey }) else { return nil }
        self = match
    }
}

extension LoanKind: StorageKeyed {}
extension PersonCategory: StorageKeyed {}
extension CategoryKind: StorageKeyed {}
extension AccountType: StorageKeyed {}

// MARK: - Account snapshot

extension AccountSummary {
    init(id: Account.ID, name: String, tint: String, type: AccountType) {
        self.id = id
        self.name = name
        self.tint = tint
        self.type = type
    }
}

/// Codable copy of `AccountSummary`, stored inline in loans, repayments, transfers…
struct AccountSnapshot: Codable, Hashable {
    var id: UUID
    var name: String
    var tint: String
    var typeKey: String

    init(_ summary: AccountSummary) {
        id = summary.id
        name = summary.name
        tint = summary.tint
        typeKey = summary.type.storageKey
    }

    var summary: AccountSummary {
        AccountSummary(id: id, name: name, tint: tint, type: AccountType(storageKey: typeKey) ?? .unknown)
    }
}

// MARK: - Account

@Model
final class AccountEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var number: String
    var typeKey: String
    var logo: String?
    @Attribute(.externalStorage) var logoData: Data?
    var tint: String
    var initialBalance: Double
    var netMovement: Double
    var createdAt: Date

    init(_ account: Account) {
        id = account.id
        name = account.name
        number = account.number
        typeKey = account.type.storageKey
        logo = account.logo
        logoData = account.logoData
        tint = account.tint
        initialBalance = account.initialBalance
        netMovement = account.netMovement
        createdAt = .now
    }

    var domain: Account {
        var account = Account(id: id, name: name, number: number,
                              type: AccountType(storageKey: typeKey) ?? .unknown,
                              balance: initialBalance, logo: logo, tint: tint, logoData: logoData)
        account.recordMovement(netMovement)
        return account
    }

    /// Edits details only; recorded movement is preserved.
    func updateDetails(from account: Account) {
        name = account.name
        number = account.number
        typeKey = account.type.storageKey
        logo = account.logo
        logoData = account.logoData
        tint = account.tint
        initialBalance = account.initialBalance
    }
}

// MARK: - Transfer

@Model
final class TransferEntity {
    @Attribute(.unique) var id: UUID
    var source: AccountSnapshot
    var destination: AccountSnapshot
    var amount: Double
    var charge: Double
    var date: Date
    var reason: String

    init(_ transfer: Transfer) {
        id = transfer.id
        source = AccountSnapshot(transfer.from)
        destination = AccountSnapshot(transfer.to)
        amount = transfer.amount
        charge = transfer.charge
        date = transfer.date
        reason = transfer.reason
    }

    var domain: Transfer {
        Transfer(id: id, from: source.summary, to: destination.summary,
                 amount: amount, charge: charge, date: date, reason: reason)
    }
}

// MARK: - Person

@Model
final class PersonEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryKey: String
    var phone: String?
    var address: String?

    init(_ person: Person) {
        id = person.id
        name = person.name
        categoryKey = person.category.storageKey
        phone = person.phone
        address = person.address
    }

    var domain: Person {
        Person(id: id, name: name,
               category: PersonCategory(storageKey: categoryKey) ?? .other,
               phone: phone, address: address)
    }

    func update(from person: Person) {
        name = person.name
        categoryKey = person.category.storageKey
        phone = person.phone
        address = person.address
    }
}

// MARK: - Loan

@Model
final class LoanEntity {
    @Attribute(.unique) var id: UUID
    var kindKey: String
    var personID: UUID
    var account: AccountSnapshot
    var principal: Double
    var interest: Double
    var date: Date
    var dueDate: Date?
    var installmentCount: Int
    var note: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RepaymentEntity.loan)
    var repayments: [RepaymentEntity] = []

    init(_ loan: Loan) {
        id = loan.id
        kindKey = loan.kind.storageKey
        personID = loan.personID
        account = AccountSnapshot(loan.account)
        principal = loan.principal
        interest = loan.interest
        date = loan.date
        dueDate = loan.dueDate
        installmentCount = loan.installmentCount
        note = loan.note
        createdAt = .now
    }

    var domain: Loan {
        Loan(id: id,
             kind: LoanKind(storageKey: kindKey) ?? .lent,
             personID: personID,
             account: account.summary,
             principal: principal,
             interest: interest,
             date: date,
             dueDate: dueDate,
             installmentCount: installmentCount,
             note: note,
             repayments: repayments.sorted { $0.order < $1.order }.map(\.domain))
    }

    func update(from loan: Loan, in context: ModelContext) {
        personID = loan.personID
        interest = loan.interest
        date = loan.date
        dueDate = loan.dueDate
        installmentCount = loan.installmentCount
        note = loan.note
        syncRepayments(loan.repayments, in: context)
    }

    /// Makes the stored repayments match `items` (insert new, update changed, delete removed).
    func syncRepayments(_ items: [Repayment], in context: ModelContext) {
        let incoming = Set(items.map(\.id))
        var existing: [UUID: RepaymentEntity] = [:]
        for stored in repayments {
            if incoming.contains(stored.id) { existing[stored.id] = stored } else { context.delete(stored) }
        }
        for (index, item) in items.enumerated() {
            if let stored = existing[item.id] {
                stored.update(from: item, order: index)
            } else {
                let created = RepaymentEntity(item, order: index)
                context.insert(created)
                created.loan = self
            }
        }
    }
}

@Model
final class RepaymentEntity {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var date: Date
    var account: AccountSnapshot
    var note: String?
    var order: Int
    var loan: LoanEntity?

    init(_ repayment: Repayment, order: Int) {
        id = repayment.id
        amount = repayment.amount
        date = repayment.date
        account = AccountSnapshot(repayment.account)
        note = repayment.note
        self.order = order
    }

    var domain: Repayment {
        Repayment(id: id, amount: amount, date: date, account: account.summary, note: note)
    }

    func update(from repayment: Repayment, order: Int) {
        amount = repayment.amount
        date = repayment.date
        account = AccountSnapshot(repayment.account)
        note = repayment.note
        self.order = order
    }
}

// MARK: - Savings

@Model
final class SavingsEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var number: String
    var accountID: UUID
    @Attribute(.externalStorage) var logoData: Data?
    var tint: String
    var startDate: Date
    var target: Double?
    var targetDate: Date?
    var note: String
    var openingBalance: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SavingsEntryEntity.savings)
    var entries: [SavingsEntryEntity] = []

    init(_ savings: SavingsAccount) {
        id = savings.id
        name = savings.name
        number = savings.number
        accountID = savings.accountID
        logoData = savings.logoData
        tint = savings.tint
        startDate = savings.startDate
        target = savings.target
        targetDate = savings.targetDate
        note = savings.note
        openingBalance = savings.openingBalance
        createdAt = .now
    }

    var domain: SavingsAccount {
        SavingsAccount(id: id, name: name, number: number, accountID: accountID,
                       logoData: logoData, tint: tint, startDate: startDate,
                       target: target, targetDate: targetDate, note: note,
                       openingBalance: openingBalance,
                       entries: entries.sorted { $0.order < $1.order }.map(\.domain))
    }

    func update(from savings: SavingsAccount, in context: ModelContext) {
        name = savings.name
        number = savings.number
        accountID = savings.accountID
        logoData = savings.logoData
        tint = savings.tint
        startDate = savings.startDate
        target = savings.target
        targetDate = savings.targetDate
        note = savings.note
        openingBalance = savings.openingBalance
        syncEntries(savings.entries, in: context)
    }

    func syncEntries(_ items: [SavingsEntry], in context: ModelContext) {
        let incoming = Set(items.map(\.id))
        var existing: [UUID: SavingsEntryEntity] = [:]
        for stored in entries {
            if incoming.contains(stored.id) { existing[stored.id] = stored } else { context.delete(stored) }
        }
        for (index, item) in items.enumerated() {
            if let stored = existing[item.id] {
                stored.update(from: item, order: index)
            } else {
                let created = SavingsEntryEntity(item, order: index)
                context.insert(created)
                created.savings = self
            }
        }
    }
}

@Model
final class SavingsEntryEntity {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var amount: Double
    var date: Date
    var note: String
    var account: AccountSnapshot?
    var order: Int
    var savings: SavingsEntity?

    init(_ entry: SavingsEntry, order: Int) {
        id = entry.id
        kindRaw = entry.kind.rawValue
        amount = entry.amount
        date = entry.date
        note = entry.note
        account = entry.account.map(AccountSnapshot.init)
        self.order = order
    }

    var domain: SavingsEntry {
        SavingsEntry(id: id, kind: SavingsEntryKind(rawValue: kindRaw) ?? .deposit,
                     amount: amount, date: date, note: note, account: account?.summary)
    }

    func update(from entry: SavingsEntry, order: Int) {
        kindRaw = entry.kind.rawValue
        amount = entry.amount
        date = entry.date
        note = entry.note
        account = entry.account.map(AccountSnapshot.init)
        self.order = order
    }
}

// MARK: - Category

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var kindKey: String
    var icon: String
    var tint: String
    var monthlyBudget: Double?
    var createdAt: Date

    init(_ category: TransactionCategory) {
        id = category.id
        name = category.name
        kindKey = category.kind.storageKey
        icon = category.icon
        tint = category.tint
        monthlyBudget = category.monthlyBudget
        createdAt = .now
    }

    var domain: TransactionCategory {
        TransactionCategory(id: id, name: name,
                            kind: CategoryKind(storageKey: kindKey) ?? .expense,
                            icon: icon, tint: tint, monthlyBudget: monthlyBudget)
    }

    func update(from category: TransactionCategory) {
        name = category.name
        icon = category.icon
        tint = category.tint
        monthlyBudget = category.monthlyBudget
    }
}

// MARK: - Income / expense entry

@Model
final class CashFlowEntryEntity {
    @Attribute(.unique) var id: UUID
    var kindKey: String
    var categoryID: UUID
    var accountID: UUID
    var amount: Double
    var date: Date
    var note: String
    var createdAt: Date

    init(_ entry: CashFlowEntry) {
        id = entry.id
        kindKey = entry.kind.storageKey
        categoryID = entry.categoryID
        accountID = entry.accountID
        amount = entry.amount
        date = entry.date
        note = entry.note
        createdAt = .now
    }

    var domain: CashFlowEntry {
        CashFlowEntry(id: id, kind: CategoryKind(storageKey: kindKey) ?? .expense,
                      categoryID: categoryID, accountID: accountID,
                      amount: amount, date: date, note: note)
    }

    func update(from entry: CashFlowEntry) {
        categoryID = entry.categoryID
        accountID = entry.accountID
        amount = entry.amount
        date = entry.date
        note = entry.note
    }
}
