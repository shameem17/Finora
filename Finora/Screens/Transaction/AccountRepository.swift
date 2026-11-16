//
//  AccountRepository.swift
//  Finora
//
//  Shared repository: Screens/Home/Repository (or a top-level Repositories group)
//

import Foundation

protocol AccountRepositoryProtocol: AnyObject {
    func fetchAccounts() -> [Account]
    /// Debits `amount + charge` from the source and credits `amount` to the destination.
    func apply(_ transfer: Transfer)
    /// Adds `delta` (negative to debit) to one account's balance.
    func adjustBalance(of id: Account.ID, by delta: Double)
}

/// In-memory implementation. Swap for SwiftData / Core Data later without
/// touching any view model.
final class InMemoryAccountRepository: AccountRepositoryProtocol {

    static let shared = InMemoryAccountRepository()

    private var accounts: [Account] = [
        .init(name: "City Bank",  number: "1234567894821",    type: .bank,    balance: 125_450.75, logo: "citybank", tint: "#007366"),
        .init(name: "bKash",      number: "01712345678",      type: .mfs,     balance: 8_320,       logo: "bkash",    tint: "#E31266"),
        .init(name: "Nagad",      number: "01898765432",      type: .mfs,     balance: 2_150.5,     logo: "nagad",    tint: "#F2661A"),
        .init(name: "PayPal",     number: "ab@mail.com 9921", type: .online,  balance: 640,         logo: "paypal",   tint: "#1A4DB3"),
        .init(name: "Payoneer",   number: "PY00551234",       type: .virtual, balance: 15_900,      logo: nil,        tint: "#6640D9"),
        .init(name: "Visa Debit", number: "4111111111113344", type: .card,    balance: 42_000,      logo: nil,        tint: "#1F2433"),
        .init(name: "Cash",       number: "0000",             type: .cash,    balance: 5_000,       logo: nil,        tint: "#2E7D32")
    ]

    init() {}

    func fetchAccounts() -> [Account] { accounts }

    func apply(_ transfer: Transfer) {
        adjustBalance(of: transfer.from.id, by: -transfer.totalDebited)
        adjustBalance(of: transfer.to.id, by: transfer.amount)
    }

    func adjustBalance(of id: Account.ID, by delta: Double) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].balance += delta
    }
}
