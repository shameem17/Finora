//
//  PersonFormViewModel.swift
//  Finora
//
//  Screens/Loan/ViewModel
//

import Foundation
import Observation

/// Keeps phone fields to digits and the few separators people actually type.
enum PhoneInput {
    static func sanitize(_ raw: String, maxLength: Int = 20) -> String {
        String(raw.filter { $0.isNumber || "+- ".contains($0) }.prefix(maxLength))
    }
}

@Observable
final class PersonFormViewModel: Identifiable, Hashable {
    
    static func == (lhs: PersonFormViewModel, rhs: PersonFormViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    

    enum Mode {
        case create
        case edit(Person)
    }

    let id = UUID()
    let mode: Mode

    var name = ""
    var category: PersonCategory = .individual
    var phone = ""
    var address = ""

    /// Loans that still point at this person; deleting is blocked while > 0.
    let linkedLoanCount: Int

    private let repository: PersonRepositoryProtocol
    private let existingPeople: [Person]
    private let onSaved: (Person) -> Void
    private let onDeleted: () -> Void

    init(mode: Mode,
         repository: PersonRepositoryProtocol,
         linkedLoanCount: Int = 0,
         onSaved: @escaping (Person) -> Void = { _ in },
         onDeleted: @escaping () -> Void = {}) {
        self.mode = mode
        self.repository = repository
        self.existingPeople = repository.fetchPeople()
        self.linkedLoanCount = linkedLoanCount
        self.onSaved = onSaved
        self.onDeleted = onDeleted

        if case .edit(let person) = mode {
            name = person.name
            category = person.category
            phone = person.phone ?? ""
            address = person.address ?? ""
        }
    }

    // MARK: Derived

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { isEditing ? "Edit Person" : "New Person" }

    private var editingID: Person.ID? {
        if case .edit(let person) = mode { return person.id }
        return nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var duplicateError: String? {
        let clash = existingPeople.contains {
            $0.id != editingID
            && $0.name.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        return clash ? "Someone with this name is already saved." : nil
    }

    var canSubmit: Bool { !trimmedName.isEmpty && duplicateError == nil }

    var canDelete: Bool { isEditing && linkedLoanCount == 0 }

    var deleteBlockedReason: String? {
        guard isEditing, linkedLoanCount > 0 else { return nil }
        let noun = linkedLoanCount == 1 ? "entry" : "entries"
        return "Linked to \(linkedLoanCount) loan \(noun). Delete or settle them first to remove this person."
    }

    // MARK: Intents

    @discardableResult
    func submit() -> Bool {
        guard canSubmit else { return false }

        let phone = self.phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = self.address.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            let person = Person(name: trimmedName,
                                category: category,
                                phone: phone.isEmpty ? nil : phone,
                                address: address.isEmpty ? nil : address)
            repository.add(person)
            onSaved(person)

        case .edit(var person):
            person.name = trimmedName
            person.category = category
            person.phone = phone.isEmpty ? nil : phone
            person.address = address.isEmpty ? nil : address
            repository.update(person)
            onSaved(person)
        }
        return true
    }

    @discardableResult
    func delete() -> Bool {
        guard canDelete, let editingID else { return false }
        repository.delete(id: editingID)
        onDeleted()
        return true
    }
}
