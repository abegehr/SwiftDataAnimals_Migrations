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
    // `.cascade` tells SwiftData to delete all animals contained in the
    // category when deleting it.
    @Relationship(deleteRule: .cascade, inverse: \Animal.category)
    var animals = [Animal]()
    
    init(name: String) {
        self.name = name
    }
}
