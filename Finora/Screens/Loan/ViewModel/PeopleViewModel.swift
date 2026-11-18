//
//  PeopleViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Combine
import Observation

struct PersonRowData: Identifiable, Equatable {
    let person: Person
    /// Positive: they owe you. Negative: you owe them.
    let netBalance: Double
    let activeCount: Int
    let totalCount: Int

    var id: Person.ID { person.id }
}

protocol PeopleViewModelProtocol: AnyObject, Observable {
    var searchText: String { get set }
    var rows: [PersonRowData] { get }
    /// `true` when nobody has been added yet (ignores search).
    var isEmpty: Bool { get }

    func load()
    func makeFormViewModel(editing person: Person?) -> PersonFormViewModel
}

@Observable
final class PeopleViewModel: PeopleViewModelProtocol, Identifiable {

    let id = UUID()

    var searchText = ""

    private var allRows: [PersonRowData] = []

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    private let dependencies: LoanDependencies

    init(dependencies: LoanDependencies) {
        self.dependencies = dependencies

        dependencies.loans.changes
            .merge(with: dependencies.people.changes)
            .sink { [weak self] in self?.load() }
            .store(in: &cancellables)

        load()
    }

    // MARK: Derived

    var isEmpty: Bool { allRows.isEmpty }

    var rows: [PersonRowData] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return allRows }
        return allRows.filter {
            $0.person.name.localizedCaseInsensitiveContains(needle)
            || ($0.person.phone ?? "").contains(needle)
        }
    }

    // MARK: Intents

    func load() {
        let loansByPerson = Dictionary(grouping: dependencies.loans.fetchLoans(), by: \.personID)

        allRows = dependencies.people.fetchPeople().map { person in
            let loans = loansByPerson[person.id] ?? []
            let net = loans.reduce(0.0) { total, loan in
                total + (loan.kind == .lent ? loan.outstanding : -loan.outstanding)
            }
            return PersonRowData(person: person,
                                 netBalance: net,
                                 activeCount: loans.filter { !$0.isSettled }.count,
                                 totalCount: loans.count)
        }
    }

    func makeFormViewModel(editing person: Person?) -> PersonFormViewModel {
        guard let person else {
            return PersonFormViewModel(mode: .create, repository: dependencies.people)
        }
        let linked = dependencies.loans.fetchLoans().filter { $0.personID == person.id }.count
        return PersonFormViewModel(mode: .edit(person),
                                   repository: dependencies.people,
                                   linkedLoanCount: linked)
    }
}
