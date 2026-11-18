//
//  LoanViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Combine
import Observation

protocol LoanViewModelProtocol: AnyObject, Observable {
    var period: ReportPeriod { get set }
    var kind: LoanKind { get set }
    var searchText: String { get set }

    var summary: LoanSummary { get }
    var sections: [LoanSection] { get }
    /// `true` when there are no entries of the selected kind at all (ignores search).
    var isEmpty: Bool { get }

    func load()
    func showDetail(of item: LoanItem)
    func makeFormViewModel() -> LoanFormViewModel
    func makePeopleViewModel() -> PeopleViewModel
    func makePersonFormViewModel() -> PersonFormViewModel
}

@Observable
final class LoanViewModel: LoanViewModelProtocol {

    // MARK: Observed state

    private var selectedPeriod: ReportPeriod = .month
    private var selectedKind: LoanKind = .lent
    private var query = ""

    private(set) var summary: LoanSummary = .empty
    private(set) var sections: [LoanSection] = []
    private(set) var isEmpty = true

    /// Each setter rebuilds only the derived state it affects, once, instead of
    /// recomputing on every view-body evaluation.
    var period: ReportPeriod {
        get { selectedPeriod }
        set {
            selectedPeriod = newValue
            rebuildSummary()
        }
    }

    var kind: LoanKind {
        get { selectedKind }
        set {
            selectedKind = newValue
            rebuildSections()
        }
    }

    var searchText: String {
        get { query }
        set {
            query = newValue
            rebuildSections()
        }
    }

    // MARK: Not observed

    @ObservationIgnored weak var router: LoanRouting?
    @ObservationIgnored private var allLoans: [Loan] = []
    @ObservationIgnored private var peopleByID: [Person.ID: Person] = [:]
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    private let dependencies: LoanDependencies
    private let calendar: Calendar

    // MARK: Init

    init(dependencies: LoanDependencies, calendar: Calendar = .current) {
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
        allLoans = dependencies.loans.fetchLoans()
        peopleByID = Dictionary(dependencies.people.fetchPeople().map { ($0.id, $0) },
                                uniquingKeysWith: { first, _ in first })
        rebuildSummary()
        rebuildSections()
    }

    func showDetail(of item: LoanItem) {
        router?.showDetail(of: item.id)
    }

    func makePeopleViewModel() -> PeopleViewModel {
        PeopleViewModel(dependencies: dependencies)
    }

    func makePersonFormViewModel() -> PersonFormViewModel {
        PersonFormViewModel(mode: .create, repository: dependencies.people)
    }

    func makeFormViewModel() -> LoanFormViewModel {
        LoanFormViewModel(mode: .create(kind: selectedKind), dependencies: dependencies, calendar: calendar)
    }

    // MARK: Derived state

    private func rebuildSummary() {
        summary = LoanSummary.make(loans: allLoans, period: selectedPeriod, calendar: calendar)
    }

    private func rebuildSections() {
        let now = Date.now
        let ofKind = allLoans.filter { $0.kind == selectedKind }
        isEmpty = ofKind.isEmpty

        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let items = ofKind
            .map { LoanItem(loan: $0, person: peopleByID[$0.personID], now: now, calendar: calendar) }
            .filter { item in
                needle.isEmpty
                || item.person.name.localizedCaseInsensitiveContains(needle)
                || (item.loan.note ?? "").localizedCaseInsensitiveContains(needle)
            }

        var overdue: [LoanItem] = []
        var active: [LoanItem] = []
        var settled: [LoanItem] = []

        for item in items {
            switch item.status {
            case .overdue:      overdue.append(item)
            case .settled:      settled.append(item)
            case .due, .open:   active.append(item)
            }
        }

        // Most late first; soonest due first (open-ended last); latest activity first.
        overdue.sort { ($0.status.overdueDays ?? 0) > ($1.status.overdueDays ?? 0) }
        active.sort { lhs, rhs in
            if lhs.status.dueRank != rhs.status.dueRank {
                return lhs.status.dueRank < rhs.status.dueRank
            }
            return lhs.loan.date > rhs.loan.date
        }
        settled.sort { $0.loan.lastActivity > $1.loan.lastActivity }

        let groups: [(LoanSection.Group, [LoanItem])] = [
            (.overdue, overdue),
            (.active, active),
            (.settled, settled)
        ]
        sections = groups
            .filter { !$0.1.isEmpty }
            .map { LoanSection(group: $0.0, items: $0.1) }
    }
}
