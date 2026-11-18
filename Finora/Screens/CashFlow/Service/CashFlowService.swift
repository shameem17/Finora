//
//  CashFlowService.swift
//  Finora
//
//  Screens/CashFlow/Service
//

import Foundation

/// Every write goes through here so account balances and records never drift apart.
protocol CashFlowServiceProtocol: AnyObject {
    /// Saves a new entry and moves the account's balance.
    func record(_ entry: CashFlowEntry)
    /// Replaces an entry: its old effect on the account is reversed, the new one applied.
    func update(_ entry: CashFlowEntry)
    /// Removes an entry and reverses its effect on the account.
    func delete(id: CashFlowEntry.ID)
}

final class CashFlowService: CashFlowServiceProtocol {

    private let entries: CashFlowRepositoryProtocol
    private let accounts: AccountRepositoryProtocol

    init(entries: CashFlowRepositoryProtocol, accounts: AccountRepositoryProtocol) {
        self.entries = entries
        self.accounts = accounts
    }

    func record(_ entry: CashFlowEntry) {
        accounts.adjustBalance(of: entry.accountID, by: entry.accountDelta)
        entries.add(entry)
    }

    func update(_ entry: CashFlowEntry) {
        guard let old = entries.entry(id: entry.id) else { return }
        accounts.adjustBalance(of: old.accountID, by: -old.accountDelta)
        accounts.adjustBalance(of: entry.accountID, by: entry.accountDelta)
        entries.update(entry)
    }

    func delete(id: CashFlowEntry.ID) {
        guard let old = entries.entry(id: id) else { return }
        accounts.adjustBalance(of: old.accountID, by: -old.accountDelta)
        entries.delete(id: id)
    }
}

struct CashFlowDependencies {
    let entries: CashFlowRepositoryProtocol
    let categories: CategoryRepositoryProtocol
    let accounts: AccountRepositoryProtocol
    let service: CashFlowServiceProtocol

    static func live() -> CashFlowDependencies {
        make(entries: InMemoryCashFlowRepository.shared,
             categories: InMemoryCategoryRepository.shared,
             accounts: InMemoryAccountRepository.shared)
    }

    #if DEBUG
    static func preview() -> CashFlowDependencies {
        let categories = InMemoryCategoryRepository()
        let accounts = InMemoryAccountRepository()
        let entries = InMemoryCashFlowRepository(
            entries: CashFlowSampleData.entries(
                categories: CategoryKind.allCases.flatMap { categories.fetchCategories(kind: $0) },
                accounts: accounts.fetchAccounts()
            )
        )
        return make(entries: entries, categories: categories, accounts: accounts)
    }
    #endif

    private static func make(entries: CashFlowRepositoryProtocol,
                             categories: CategoryRepositoryProtocol,
                             accounts: AccountRepositoryProtocol) -> CashFlowDependencies {
        CashFlowDependencies(entries: entries, categories: categories, accounts: accounts,
                             service: CashFlowService(entries: entries, accounts: accounts))
    }
}

#if DEBUG
enum CashFlowSampleData {
    /// A few records this month so the charts aren't empty in debug builds.
    static func entries(categories: [TransactionCategory], accounts: [Account]) -> [CashFlowEntry] {
        guard let account = accounts.first else { return [] }
        let amounts: [String: Double] = [
            "Salary": 65_000, "Freelance": 12_000, "Gift": 2_000,
            "Food & Dining": 4_200, "Groceries": 3_100, "Transport": 1_400, "Bills & Utilities": 2_800
        ]
        return categories.compactMap { category in
            amounts[category.name].map {
                CashFlowEntry(kind: category.kind, categoryID: category.id, accountID: account.id,
                              amount: $0, date: .now, note: "")
            }
        }
    }
}
#endif
