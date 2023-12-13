//
//  PersistenceContainerTests.swift
//  
//
//  Created by Toomas Vahter on 13.12.2023.
//

@testable import Persistence
import XCTest

final class PersistenceContainerTests: XCTestCase {
    func testLoadingCoreDataModel() async throws {
        let container = PersistenceConteiner(inMemory: true)
        try await container.load()
    }
}
