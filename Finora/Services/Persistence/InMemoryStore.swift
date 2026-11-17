//
//  InMemoryStore.swift
//  Finora
//
//  Services/Persistence
//
//  The one in-memory collection behind every repository (loans, people,
//  savings, categories). Swap the repositories' storage for SwiftData / Core
//  Data later without touching a single view model.
//

import Foundation
import Combine

/// Anything that tells screens when its data changed, so they refresh
/// instead of polling.
protocol ChangeNotifying: AnyObject {
    /// Emits after every mutation.
    var changes: AnyPublisher<Void, Never> { get }
}

final class InMemoryStore<Item: Identifiable> {

    private(set) var items: [Item]
    private let subject = PassthroughSubject<Void, Never>()

    init(_ items: [Item] = []) {
        self.items = items
    }

    var changes: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func item(id: Item.ID) -> Item? {
        items.first { $0.id == id }
    }

    func add(_ item: Item) {
        items.append(item)
        subject.send()
    }

    func update(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        subject.send()
    }

    func remove(id: Item.ID) {
        items.removeAll { $0.id == id }
        subject.send()
    }
}
