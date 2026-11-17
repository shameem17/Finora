//
//  PersonRepository.swift
//  Finora
//
//  Screens/Loan/Repository
//

import Foundation
import Combine

protocol PersonRepositoryProtocol: ChangeNotifying {
    /// Sorted A–Z.
    func fetchPeople() -> [Person]
    func person(id: Person.ID) -> Person?
    func add(_ person: Person)
    func update(_ person: Person)
    func delete(id: Person.ID)
}

/// In-memory implementation. Swap for SwiftData / Core Data later without
/// touching any view model.
final class InMemoryPersonRepository: PersonRepositoryProtocol {

    static let shared: InMemoryPersonRepository = {
        #if DEBUG
        return InMemoryPersonRepository(people: LoanSampleData.people)
        #else
        return InMemoryPersonRepository()
        #endif
    }()

    private let store: InMemoryStore<Person>

    init(people: [Person] = []) {
        store = InMemoryStore(people)
    }

    var changes: AnyPublisher<Void, Never> { store.changes }

    func fetchPeople() -> [Person] {
        store.items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func person(id: Person.ID) -> Person? { store.item(id: id) }
    func add(_ person: Person) { store.add(person) }
    func update(_ person: Person) { store.update(person) }
    func delete(id: Person.ID) { store.remove(id: id) }
}
