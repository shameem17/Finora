//
//  TransferRepository.swift
//  Finora
//
//  Screens/Transaction/Repository
//

import Foundation

protocol TransferRepositoryProtocol: AnyObject {
    /// Newest first.
    func fetchTransfers() -> [Transfer]
    func add(_ transfer: Transfer)
}

final class InMemoryTransferRepository: TransferRepositoryProtocol {
    
    static let shared = InMemoryTransferRepository()
    
    private var transfers: [Transfer]
    
    init() {
        self.transfers = [Transfer(id: UUID(),
                                   from: AccountSummary(Account(name: "city", number: "37628300", type: .bank, balance: 2343, logo: "", tint: "#f34fb2")),
                                   to: AccountSummary(Account(name: "bkash", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#ff1276")), amount: 2344, charge: 10, date: Date.now, reason: "ha ha ki r reason"),
                          Transfer(id: UUID(),
                                   from: AccountSummary(Account(name: "nagad", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#f34fb2")),
                                   to: AccountSummary(Account(name: "bkash", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#ff1276")), amount: 2344, charge: 10, date: Date.now, reason: "ha ha ki r reason")
                          
        ]
    }
    
    func fetchTransfers() -> [Transfer] {
        transfers.sorted { $0.date > $1.date }
    }
    
    func add(_ transfer: Transfer) {
        transfers.append(transfer)
    }
}
