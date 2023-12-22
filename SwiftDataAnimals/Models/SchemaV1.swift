//
//  SchemaV1.swift
//  SwiftDataAnimals
//
//  Created by Anton Begehr on 19.12.23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Animal.self, AnimalCategory.self]
    }
}

extension SchemaV1 {
    @Model
    final class Animal {
        var name: String?
        var diet: Diet?
        var category: AnimalCategory?
        
        init(name: String, diet: Diet) {
            self.name = name
            self.diet = diet
        }
        
        enum Diet: String, CaseIterable, Codable {
            case herbivorous = "Herbivore"
            case carnivorous = "Carnivore"
            case omnivorous = "Omnivore"
        }
    }
    
    @Model
    final class AnimalCategory {
        var name: String?
        // `.cascade` tells SwiftData to delete all animals contained in the
        // category when deleting it.
        @Relationship(deleteRule: .cascade, inverse: \Animal.category)
        var animals: [Animal]? = []
        
        init(name: String) {
            self.name = name
        }
    }
}
