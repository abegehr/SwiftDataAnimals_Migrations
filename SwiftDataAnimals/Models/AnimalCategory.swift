/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model class that defines the properties of an animal category.
*/

import Foundation
import SwiftData

@Model
final class AnimalCategory {
    @Attribute(.unique) var name: String
    // When deleting a category, `.cascade` deletes all animals in that category.
    @Relationship(deleteRule: .cascade, inverse: \Animal.category)
    var animals = [Animal]()
    
    init(name: String) {
        self.name = name
    }
}
