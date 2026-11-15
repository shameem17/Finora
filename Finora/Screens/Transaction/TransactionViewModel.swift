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
    
    var summary: TransferSummary
    var sections: [TransferSection]
    
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
        self.summary = TransferSummary(totalAmount: 253, totalCharges: 10, count: 10)
        self.sections = [TransferSection(id: Date.now, title: "bKash Transfer", transfers: [Transfer(id: UUID(),
                                                                                                     from: AccountSummary(Account(name: "city", number: "37628300", type: .bank, balance: 2343, logo: "", tint: "#f34fb2")),
                                                                                                     to: AccountSummary(Account(name: "bkash", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#ff1276")), amount: 2344, charge: 10, date: Date.now, reason: "ha ha ki r reason"),
                                                                                            Transfer(id: UUID(),
                                                                                                     from: AccountSummary(Account(name: "nagad", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#f34fb2")),
                                                                                                     to: AccountSummary(Account(name: "bkash", number: "37628300", type: .mfs, balance: 2343, logo: "", tint: "#ff1276")), amount: 2344, charge: 10, date: Date.now, reason: "ha ha ki r reason")
                                                                                            
        ])]
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
