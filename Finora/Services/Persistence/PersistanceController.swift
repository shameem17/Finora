//
//  PersistanceController.swift
//  Finora
//
//  Created by Shameem on 11/18/26.
//


import Foundation
import SwiftData
import Combine
import os

// MARK: - Unit of work

/// Groups several repository / service writes into one atomic commit.
protocol UnitOfWork: AnyObject {
    @discardableResult
    func perform<T>(_ work: () throws -> T) rethrows -> T
}

/// For previews and tests with in-memory repositories: no batching needed.
final class ImmediateUnitOfWork: UnitOfWork {
    func perform<T>(_ work: () throws -> T) rethrows -> T { try work() }
}

// MARK: - Schema

nonisolated enum FinoraSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [AccountEntity.self, TransferEntity.self,
         PersonEntity.self, LoanEntity.self, RepaymentEntity.self,
         SavingsEntity.self, SavingsEntryEntity.self,
         CategoryEntity.self, CashFlowEntryEntity.self]
    }
}

nonisolated enum FinoraMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FinoraSchemaV1.self] }
    /// Add a stage here when `FinoraSchemaV2` is introduced.
    static var stages: [MigrationStage] { [] }
}

// MARK: - Controller

final class PersistenceController: UnitOfWork {

    static let shared: PersistenceController = {
        do {
            let controller = try PersistenceController()
            DefaultDataSeeder.seedIfNeeded(in: controller)
            return controller
        } catch {
            fatalError("Finora could not open its database: \(error)")
        }
    }()

    let container: ModelContainer
    var context: ModelContext { container.mainContext }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.finora.app",
        category: "Persistence"
    )

    private var depth = 0
    private var didFail = false
    private var pendingSignals: [ObjectIdentifier: PassthroughSubject<Void, Never>] = [:]

    init(inMemory: Bool = false) throws {
        let schema = Schema(versionedSchema: FinoraSchemaV1.self)
        let configuration: ModelConfiguration
        var protectedDirectory: URL?

        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            let directory = try Self.storeDirectory()
            protectedDirectory = directory
            configuration = ModelConfiguration("Finora",
                                               schema: schema,
                                               url: directory.appendingPathComponent("Finora.store"),
                                               cloudKitDatabase: .none)
        }

        container = try ModelContainer(for: schema,
                                       migrationPlan: FinoraMigrationPlan.self,
                                       configurations: [configuration])
        // Saves happen only at the end of a unit of work, never at a random moment.
        container.mainContext.autosaveEnabled = false

        if let protectedDirectory { Self.applyFileProtection(to: protectedDirectory) }
    }

    // MARK: UnitOfWork

    func perform<T>(_ work: () throws -> T) rethrows -> T {
        depth += 1
        defer {
            depth -= 1
            if depth == 0 { finish() }
        }
        do {
            return try work()
        } catch {
            didFail = true
            throw error
        }
    }

    /// Runs one repository write. Joins the surrounding transaction if there is one,
    /// otherwise commits on its own. `signal` fires after the commit.
    func write(notifying signal: PassthroughSubject<Void, Never>, _ body: (ModelContext) -> Void) {
        perform {
            body(context)
            pendingSignals[ObjectIdentifier(signal)] = signal
        }
    }

    // MARK: Reads

    func fetchAll<E: PersistentModel>(_ type: E.Type,
                                      matching predicate: Predicate<E>? = nil,
                                      sortBy: [SortDescriptor<E>] = []) -> [E] {
        let descriptor = FetchDescriptor<E>(predicate: predicate, sortBy: sortBy)
        do {
            return try context.fetch(descriptor)
        } catch {
            Self.logger.error("Fetch failed: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    func first<E: PersistentModel>(matching predicate: Predicate<E>) -> E? {
        var descriptor = FetchDescriptor<E>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func count<E: PersistentModel>(of type: E.Type) -> Int {
        (try? context.fetchCount(FetchDescriptor<E>())) ?? 0
    }

    // MARK: Private

    private func finish() {
        if didFail {
            context.rollback()
        } else if context.hasChanges {
            do {
                try context.save()
            } catch {
                Self.logger.error("Save failed, rolled back: \(error.localizedDescription, privacy: .public)")
                context.rollback()
            }
        }
        didFail = false

        // Notify after commit / rollback so observers always read stored truth.
        let signals = Array(pendingSignals.values)
        pendingSignals.removeAll()
        signals.forEach { $0.send() }
    }

    private static func storeDirectory() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
        let directory = base.appendingPathComponent("Finora", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        )
        return directory
    }

    /// Encrypts the store (and its -wal / -shm files) with the device key.
    private static func applyFileProtection(to directory: URL) {
        let manager = FileManager.default
        let attributes: [FileAttributeKey: Any] = [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        try? manager.setAttributes(attributes, ofItemAtPath: directory.path)
        for name in (try? manager.contentsOfDirectory(atPath: directory.path)) ?? [] {
            try? manager.setAttributes(attributes, ofItemAtPath: directory.appendingPathComponent(name).path)
        }
    }
}

// MARK: - First-launch data

/// Seeds the default categories exactly once, so a user who deletes them is never re-seeded.
enum DefaultDataSeeder {
    private static let key = "finora.seed.categories.v1"

    static func seedIfNeeded(in persistence: PersistenceController, defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: key) else { return }

        persistence.perform {
            guard persistence.count(of: CategoryEntity.self) == 0 else { return }
            for category in TransactionCategory.defaults {
                persistence.context.insert(CategoryEntity(category))
            }
        }
        if persistence.count(of: CategoryEntity.self) > 0 {
            defaults.set(true, forKey: key)
        }
    }
}
