//
//  PersonModels.swift
//  Finora
//
//  Screens/Loan/Model
//

import Foundation

// MARK: - Category

/// Who the other side of a loan is. Besides friends and family, a user can
/// borrow from (or lend through) a bank or a mobile wallet such as bKash / Nagad.
enum PersonCategory: String, CaseIterable, Identifiable, Hashable {
    case individual = "Person"
    case bank = "Bank"
    case wallet = "Mobile wallet"
    case other = "Other"

    var id: Self { self }
    var title: String { rawValue }

    var icon: String {
        switch self {
        case .individual: return "person.fill"
        case .bank:       return "building.columns.fill"
        case .wallet:     return "iphone.gen3"
        case .other:      return "ellipsis"
        }
    }
}

// MARK: - Person

struct Person: Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: PersonCategory
    var phone: String?
    var address: String?

    init(id: UUID = UUID(),
         name: String,
         category: PersonCategory = .individual,
         phone: String? = nil,
         address: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.phone = phone
        self.address = address
    }

    /// Shown when a loan outlives the person it points to (defensive only).
    static func unknown(id: UUID) -> Person {
        Person(id: id, name: "Unknown", category: .other)
    }

    var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    /// Stable across launches (`String.hashValue` is randomised per process),
    /// so a person keeps the same avatar colour everywhere.
    var colorSeed: Int {
        name.unicodeScalars.reduce(7) { ($0 &* 31 &+ Int($1.value)) & 0x7fff_ffff }
    }
}
