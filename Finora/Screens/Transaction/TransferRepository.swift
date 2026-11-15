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

    private var transfers: [Transfer] = []

    init() {}

    func fetchTransfers() -> [Transfer] {
        transfers.sorted { $0.date > $1.date }
    }

    func add(_ transfer: Transfer) {
        transfers.append(transfer)
    }
}
