/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension that creates animal instances for use as sample data.
*/

import Foundation

extension Animal {
    static let dog = Animal(name: "Dog", diet: .carnivorous)
    static let cat = Animal(name: "Cat", diet: .carnivorous)
    static let kangaroo = Animal(name: "Red kangaroo", diet: .herbivorous)
    static let gibbon = Animal(name: "Southern gibbon", diet: .herbivorous)
    static let sparrow = Animal(name: "House sparrow", diet: .omnivorous)
    static let newt = Animal(name: "Newt", diet: .carnivorous)
}
