/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension that creates animal category instances for use as sample data.
*/

import Foundation
import SwiftData

extension AnimalCategory {
    static let amphibian = AnimalCategory(name: "Amphibian")
    static let bird = AnimalCategory(name: "Bird")
    static let fish = AnimalCategory(name: "Fish")
    static let invertebrate = AnimalCategory(name: "Invertebrate")
    static let mammal = AnimalCategory(name: "Mammal")
    static let reptile = AnimalCategory(name: "Reptile")

    static func insertSampleData(modelContext: ModelContext) {
        // Add the animal categories to the model context.
        modelContext.insert(amphibian)
        modelContext.insert(bird)
        modelContext.insert(fish)
        modelContext.insert(invertebrate)
        modelContext.insert(mammal)
        modelContext.insert(reptile)
        
        // Add the animals to the model context.
        modelContext.insert(Animal.dog)
        modelContext.insert(Animal.cat)
        modelContext.insert(Animal.kangaroo)
        modelContext.insert(Animal.gibbon)
        modelContext.insert(Animal.sparrow)
        modelContext.insert(Animal.newt)
        
        // Set the category for each animal.
        Animal.dog.category = mammal
        Animal.cat.category = mammal
        Animal.kangaroo.category = mammal
        Animal.gibbon.category = mammal
        Animal.sparrow.category = bird
        Animal.newt.category = amphibian
    }
    
    static func reloadSampleData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: AnimalCategory.self)
            insertSampleData(modelContext: modelContext)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
