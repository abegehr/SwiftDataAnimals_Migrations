//
//  Model.swift
//  SwiftDataAnimals
//
//  Created by Anton Begehr on 19.12.23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SwiftData
import OSLog
import CoreData

private let logger = Logger(subsystem: "com.example.apple-samplecode.SwiftDataAnimals", category: "Model")

// MARK: Model Container

@discardableResult
func setupModelContainer(for versionedSchema: VersionedSchema.Type = SchemaLatest.self, url: URL? = nil, useCloudKit: Bool = true, rollback: Bool = false) throws -> ModelContainer {
    
#if DEBUG
    // disable CloudKit when running tests
    var useCloudKit = useCloudKit
    let runningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil // !TODO: is this safe?
    if (runningTest) {
        logger.info("setup - disabling CloudKit on testing run.")
        useCloudKit = false
    }
#endif
    
    do {
        logger.info("setup - versionedSchema: \(String(describing: versionedSchema)), url: \(String(describing: url)), useCloudKit: \(useCloudKit), rollback: \(rollback)")
        
        let schema = Schema(versionedSchema: versionedSchema)
        logger.info("setup - schema: \(String(describing: schema))")
        
        var config: ModelConfiguration
        if let url = url {
            config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: useCloudKit ? .automatic : .none)
        } else {
            config = ModelConfiguration(schema: schema, cloudKitDatabase: useCloudKit ? .automatic : .none)
        }
        logger.info("setup - config: \(String(describing: config))")
        
#if DEBUG
        if useCloudKit {
            // TODO: does this run on an iOS device w/o iCloud account?
            try initCloudKitDevelopmentSchema(config: config)
        }
#endif
        
        let container = try ModelContainer(
            for: schema,
            migrationPlan: rollback ? RollbackMigrationPlan.self : MigrationPlan.self,
            configurations: [config]
        )
        logger.info("setup -> \(String(describing: container))")
        
        return container
    } catch {
        logger.error("setup - \(error)")
        throw ModelError.setup(error: error)
    }
}

/// Initialize the CloudKit development schema: https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices#Initialize-the-CloudKit-development-schema
func initCloudKitDevelopmentSchema(config: ModelConfiguration) throws {
    logger.info("initCloudKitDevelopmentSchema()")
    
    // Use an autorelease pool to make sure Swift deallocates the persistent
    // container before setting up the SwiftData stack.
    try autoreleasepool {
        let desc = NSPersistentStoreDescription(url: config.url)
        let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.apple-samplecode.SwiftDataAnimalsEW3E677XMJ")
        desc.cloudKitContainerOptions = opts
        // Load the store synchronously so it completes before initializing the
        // CloudKit schema.
        desc.shouldAddStoreAsynchronously = false
        if let mom = NSManagedObjectModel.makeManagedObjectModel(for: SchemaLatest.models) {
            let container = NSPersistentCloudKitContainer(name: config.name, managedObjectModel: mom)
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores {_, err in
                if let err {
                    fatalError(err.localizedDescription)
                }
            }
            // Initialize the CloudKit schema after the store finishes loading.
            try container.initializeCloudKitSchema()
            // Remove and unload the store from the persistent container.
            if let store = container.persistentStoreCoordinator.persistentStores.first {
                try container.persistentStoreCoordinator.remove(store)
            }
        }
    }
}

enum ModelError: LocalizedError {
    case setup(error: Error)
}

// MARK: Migration Plan

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    // MARK: Migration Stages
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: { context in
            logger.info("migrateV1toV2.willMigrate()")
        },
        didMigrate: { context in
            logger.info("migrateV1toV2.didMigrate()")
            
            let animals = try context.fetch(FetchDescriptor<SchemaV2.Animal>())
            logger.info("migrateV1toV2 - found \(animals.count) animals")
            
            // default all animals to not extinct
            for animal in animals {
                animal.extinct = false
                logger.info("migrateV1toV2 - updated animal \(animal.name ?? "Unknown")")
            }
            
            try context.save()
        }
    )
}

// MARK: Rollback Migration Plan

enum RollbackMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV2.self, SchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV2toV1]
    }
    
    // MARK: Migration Stages
    
    static let migrateV2toV1 = MigrationStage.custom(
        fromVersion: SchemaV2.self,
        toVersion: SchemaV1.self,
        willMigrate: { context in
            logger.info("migrateV2toV1.willMigrate()")
        },
        didMigrate: { context in
            logger.info("migrateV2toV1.didMigrate()")
        }
    )
}
