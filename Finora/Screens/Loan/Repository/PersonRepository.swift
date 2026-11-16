//
//  PersonRepository.swift
//  Finora
//
//  Screens/Loan/Repository
//

import Foundation
import Combine

protocol PersonRepositoryProtocol: AnyObject {
    /// Emits after every mutation so screens can refresh without polling.
    var changes: AnyPublisher<Void, Never> { get }

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

    private var people: [Person]
    private let subject = PassthroughSubject<Void, Never>()

    init(people: [Person] = []) {
        self.people = people
    }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func fetchPeople() -> [Person] {
        people.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func person(id: Person.ID) -> Person? {
        people.first { $0.id == id }
    }

    func add(_ person: Person) {
        people.append(person)
        subject.send()
    }

    func update(_ person: Person) {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[index] = person
        subject.send()
    }

    func delete(id: Person.ID) {
        people.removeAll { $0.id == id }
        subject.send()
    }
}
