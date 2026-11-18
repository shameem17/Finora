//
//  TransactionViewModel.swift
//  Finora
//
//  Screens/Transaction/ViewModel
//

import Foundation
import Combine
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
    @ObservationIgnored private var allTransfers: [Transfer] = []
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

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
    private let unitOfWork: UnitOfWork
    private let calendar: Calendar

    init(accountRepository: AccountRepositoryProtocol,
         transferRepository: TransferRepositoryProtocol,
         unitOfWork: UnitOfWork = ImmediateUnitOfWork(),
         calendar: Calendar = .current) {
        self.accountRepository = accountRepository
        self.transferRepository = transferRepository
        self.unitOfWork = unitOfWork
        self.calendar = calendar

        transferRepository.changes
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
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

    /// Saves the transfer and moves both balances in one atomic commit.
    private func record(_ transfer: Transfer) {
        unitOfWork.perform {
            // Re-check against stored balances: the form may have been open a while.
            guard let source = accountRepository.account(id: transfer.from.id),
                  accountRepository.account(id: transfer.to.id) != nil,
                  source.balance + 0.005 >= transfer.totalDebited else { return }

            transferRepository.add(transfer)
            accountRepository.apply(transfer)
        }
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
