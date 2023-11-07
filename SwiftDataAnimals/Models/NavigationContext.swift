/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable type that manages attributes of the app's navigation system.
*/

import SwiftUI

@Observable
class NavigationContext {
    var selectedAnimalCategoryName: String?
    var selectedAnimal: Animal?
    var columnVisibility: NavigationSplitViewVisibility
    
    var sidebarTitle = "Categories"
    
    var contentListTitle: String {
        if let selectedAnimalCategoryName {
            selectedAnimalCategoryName
        } else {
            ""
        }
    }
    
    init(selectedAnimalCategoryName: String? = nil,
         selectedAnimal: Animal? = nil,
         columnVisibility: NavigationSplitViewVisibility = .automatic) {
        self.selectedAnimalCategoryName = selectedAnimalCategoryName
        self.selectedAnimal = selectedAnimal
        self.columnVisibility = columnVisibility
    }
}
