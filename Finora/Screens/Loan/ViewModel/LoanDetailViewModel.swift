//
//  LoanDetailViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Combine
import Observation

protocol LoanDetailViewModelProtocol: AnyObject, Observable {
    /// `nil` once the loan no longer exists.
    var item: LoanItem? { get }
    var installments: [Installment] { get }
    /// Newest first.
    var repayments: [Repayment] { get }

    func load()
    func makeRepaymentFormViewModel() -> RepaymentFormViewModel?
    func makeEditFormViewModel() -> LoanFormViewModel?
    func deleteRepayment(id: Repayment.ID)
    func deleteLoan()
}

@Observable
final class LoanDetailViewModel: LoanDetailViewModelProtocol {

    private(set) var item: LoanItem?
    private(set) var installments: [Installment] = []
    private(set) var repayments: [Repayment] = []

    @ObservationIgnored weak var router: LoanRouting?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    private let loanID: Loan.ID
    private let dependencies: LoanDependencies
    private let calendar: Calendar

    init(loanID: Loan.ID, dependencies: LoanDependencies, calendar: Calendar = .current) {
        self.loanID = loanID
        self.dependencies = dependencies
        self.calendar = calendar

        dependencies.loans.changes
            .merge(with: dependencies.people.changes)
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    // MARK: Intents

    func load() {
        guard let loan = dependencies.loans.loan(id: loanID) else {
            item = nil
            installments = []
            repayments = []
            return
        }

        item = LoanItem(loan: loan,
                        person: dependencies.people.person(id: loan.personID),
                        calendar: calendar)
        installments = loan.installments(calendar: calendar)
        repayments = loan.repayments.sorted { $0.date > $1.date }
    }

    func makeRepaymentFormViewModel() -> RepaymentFormViewModel? {
        guard let item, !item.loan.isSettled else { return nil }
        return RepaymentFormViewModel(item: item, dependencies: dependencies, calendar: calendar)
    }

    func makeEditFormViewModel() -> LoanFormViewModel? {
        guard let item else { return nil }
        return LoanFormViewModel(mode: .edit(item.loan), dependencies: dependencies, calendar: calendar)
    }

    func deleteRepayment(id: Repayment.ID) {
        dependencies.service.deleteRepayment(id: id, from: loanID)
    }

    func deleteLoan() {
        dependencies.service.delete(loanID: loanID)
        router?.closeDetail()
    }
}
