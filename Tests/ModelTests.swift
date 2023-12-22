//
//  ModelTests.swift
//  SwiftDataAnimals
//
//  Created by Anton Begehr on 19.12.23.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest
@testable import SwiftDataAnimals
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.example.apple-samplecode.SwiftDataAnimalsTests", category: "ModelTests")

final class ModelTests: XCTestCase {
    
    var url: URL!
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.url = FileManager.default.temporaryDirectory.appending(component: "default.store")
        logger.debug("url: \(self.url)")
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Cleanup resources
        self.container = nil
        self.context = nil
        
        // Delete database
        try FileManager.default.removeItem(at: self.url)
        try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-shm"))
        try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-wal"))
    }
    
    func testMigrationV1toV2() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // Setup V1
        container = try setupModelContainer(for: SchemaV1.self, url: self.url, useCloudKit: false)
        context = ModelContext(container)
        try loadSampleDataSchemaV1(context: context)
        let animalsV1 = try context.fetch(FetchDescriptor<SchemaV1.Animal>())
        
        // Migration V1 -> V2
        container = try setupModelContainer(for: SchemaV2.self, url: self.url, useCloudKit: false)
        context = ModelContext(container)
        
        // Assert: all animals should have extinct==false
        let animals = try context.fetch(FetchDescriptor<SchemaV2.Animal>())
        XCTAssert(animals.allSatisfy { $0.extinct == false }, "Not all animals have extinct set to false.")
        
        // Rollback V2 -> V1
        container = try setupModelContainer(for: SchemaV1.self, url: self.url, useCloudKit: false, rollback: true)
        context = ModelContext(container)
        
        // Assert: there are the same number of animals as before the migration
        let animalsV1Post = try context.fetch(FetchDescriptor<SchemaV1.Animal>())
        XCTAssertEqual(animalsV1.count, animalsV1Post.count, "Number of animals before and after migration and rollback are different.")
    }
    
    //    func testPerformanceExample() throws {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
}

// MARK: Sample Data

func loadSampleDataSchemaV1(context: ModelContext) throws {
    typealias AnimalCategory = SchemaV1.AnimalCategory
    typealias Animal = SchemaV1.Animal
    
    // Add the animal categories to the model context.
    
    let amphibian = AnimalCategory(name: "Amphibian")
    let bird = AnimalCategory(name: "Bird")
    let fish = AnimalCategory(name: "Fish")
    let invertebrate = AnimalCategory(name: "Invertebrate")
    let mammal = AnimalCategory(name: "Mammal")
    let reptile = AnimalCategory(name: "Reptile")
    
    context.insert(amphibian)
    context.insert(bird)
    context.insert(fish)
    context.insert(invertebrate)
    context.insert(mammal)
    context.insert(reptile)
    
    // Add the animals to the model context.
    
    let dog = Animal(name: "Dog", diet: .carnivorous)
    let cat = Animal(name: "Cat", diet: .carnivorous)
    let kangaroo = Animal(name: "Red kangaroo", diet: .herbivorous)
    let gibbon = Animal(name: "Southern gibbon", diet: .herbivorous)
    let sparrow = Animal(name: "House sparrow", diet: .omnivorous)
    let newt = Animal(name: "Newt", diet: .carnivorous)
    
    context.insert(dog)
    context.insert(cat)
    context.insert(kangaroo)
    context.insert(gibbon)
    context.insert(sparrow)
    context.insert(newt)
    
    // Set the category for each animal.
    
    dog.category = mammal
    cat.category = mammal
    kangaroo.category = mammal
    gibbon.category = mammal
    sparrow.category = bird
    newt.category = amphibian
    
    try context.save()
}
