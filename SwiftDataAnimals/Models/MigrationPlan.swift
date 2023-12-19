//
//  MigrationPlan.swift
//  SwiftDataAnimals
//
//  Created by Anton Begehr on 19.12.23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.example.apple-samplecode.SwiftDataAnimals", category: "Model")

func setupModelContainer() -> ModelContainer {
    do {
        let config = ModelConfiguration()
        
        let container = try ModelContainer(
            for: AnimalCategory.self,
            migrationPlan: MigrationPlan.self,
            configurations: config
        )
        
        //            let schema = Schema(versionedSchema: SchemaLatest.self)
        //            logger.info("init - schema: \(schema)")
        //            self.container = try ModelContainer(
        //                for: Schema(versionedSchema: SchemaLatest.self),
        //                migrationPlan: MigrationPlan.self,
        //                configurations: [config]
        //            )
        
        logger.info("init - config: \(String(describing: config))")
        logger.info("init - setup container: \(String(describing: container))")
        
        return container
    } catch {
        fatalError("Failed to setup ModelContainer - Error: \(error)")
    }
}

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
