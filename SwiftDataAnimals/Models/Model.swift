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

private let logger = Logger(subsystem: "com.example.apple-samplecode.SwiftDataAnimals", category: "Model")

// MARK: Model Container

func setupModelContainer(for versionedSchema: VersionedSchema.Type = SchemaLatest.self, url: URL? = nil, rollback: Bool = false) throws -> ModelContainer {
    do {
        logger.info("setup - versionedSchema: \(String(describing: versionedSchema))")
        
        let schema = Schema(versionedSchema: versionedSchema)
        logger.info("setup - schema: \(String(describing: schema))")
        
        var config: ModelConfiguration
        if let url = url {
            config = ModelConfiguration(schema: schema, url: url)
        } else {
            config = ModelConfiguration(schema: schema)
        }
        logger.info("setup - config: \(String(describing: config))")
        
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
                logger.info("migrateV1toV2 - updated animal \(animal.name)")
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
