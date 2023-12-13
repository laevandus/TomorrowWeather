//
//  PersistenceConteiner.swift
//
//
//  Created by Toomas Vahter on 13.12.2023.
//

import CoreData
import Foundation

// TODO: Review versioning and migrations

@dynamicMemberLookup final class PersistenceConteiner {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let modelURL = Bundle.module.url(forResource: "DataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentContainer(name: "DataModel", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
    }

    func load() async throws {
        let _: NSPersistentStoreDescription = try await withCheckedThrowingContinuation { continuation in
            container.loadPersistentStores { description, error in
                if let error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: description)
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    subscript<T>(dynamicMember keyPath: KeyPath<NSPersistentContainer, T>) -> T {
        return container[keyPath: keyPath]
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
