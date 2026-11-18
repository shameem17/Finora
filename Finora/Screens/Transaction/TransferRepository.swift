//
//  TransferRepository.swift
//  Finora
//
//  Screens/Transaction/Repository
//

import Foundation
import Combine

protocol TransferRepositoryProtocol: ChangeNotifying {
    /// Newest first.
    func fetchTransfers() -> [Transfer]
    func add(_ transfer: Transfer)
}

/// In-memory implementation for previews and tests. The app uses `SwiftDataTransferRepository`.
final class InMemoryTransferRepository: TransferRepositoryProtocol {

    private var transfers: [Transfer]
    private let subject = PassthroughSubject<Void, Never>()

    init(transfers: [Transfer] = []) {
        self.transfers = transfers
    }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchTransfers() -> [Transfer] {
        transfers.sorted { $0.date > $1.date }
    }

    func add(_ transfer: Transfer) {
        transfers.append(transfer)
        subject.send()
    }
}
