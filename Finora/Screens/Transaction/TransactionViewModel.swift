//
//  TransactionViewModel.swift
//  Finora
//
//  Screens/Transaction/ViewModel
//

import Foundation
import Observation

protocol TransactionViewModelProtocol: AnyObject, Observable {
    var period: TransferPeriod { get set }
    var summary: TransferSummary { get }
    var sections: [TransferSection] { get }

    func load()
    func makeFormViewModel() -> TransferFormViewModel
}

@Observable
final class TransactionViewModel: TransactionViewModelProtocol {

    // MARK: State

    private var selectedPeriod: TransferPeriod = .month
    private var allTransfers: [Transfer] = []

    private(set) var summary: TransferSummary = .empty
    private(set) var sections: [TransferSection] = []

    /// Changing the period rebuilds the derived state once, instead of
    /// recomputing it on every view-body evaluation.
    var period: TransferPeriod {
        get { selectedPeriod }
        set {
            selectedPeriod = newValue
            rebuild()
        }
    }

    // MARK: Dependencies

    private let accountRepository: AccountRepositoryProtocol
    private let transferRepository: TransferRepositoryProtocol
    private let calendar: Calendar

    init(accountRepository: AccountRepositoryProtocol,
         transferRepository: TransferRepositoryProtocol,
         calendar: Calendar = .current) {
        self.accountRepository = accountRepository
        self.transferRepository = transferRepository
        self.calendar = calendar
    }

    // MARK: Intents

    func load() {
        allTransfers = transferRepository.fetchTransfers()
        rebuild()
    }

    func makeFormViewModel() -> TransferFormViewModel {
        TransferFormViewModel(accounts: accountRepository.fetchAccounts()) { [weak self] transfer in
            self?.record(transfer)
        }
    }

    // MARK: Private

    private func record(_ transfer: Transfer) {
        transferRepository.add(transfer)
        accountRepository.apply(transfer)
        load()
    }

    private func rebuild() {
        let visible = allTransfers.filter { selectedPeriod.contains($0.date, calendar: calendar) }

        summary = TransferSummary(
            totalAmount: visible.reduce(0) { $0 + $1.amount },
            totalCharges: visible.reduce(0) { $0 + $1.charge },
            count: visible.count
        )

        sections = Dictionary(grouping: visible) { calendar.startOfDay(for: $0.date) }
            .map { day, items in
                TransferSection(id: day,
                                title: title(for: day),
                                transfers: items.sorted { $0.date > $1.date })
            }
            .sorted { $0.id > $1.id }
    }

    private func title(for day: Date) -> String {
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.wide).day().month(.abbreviated))
    }
}
