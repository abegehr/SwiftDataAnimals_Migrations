/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable type that manages attributes of the app's navigation system.
*/

import SwiftUI

// For more information, see the iOS & iPadOS 17 Release Notes. (113978783)
class NavigationContext: ObservableObject {
    @Published var selectedAnimalCategoryName: String?
    @Published var selectedAnimal: Animal?
    @Published var columnVisibility: NavigationSplitViewVisibility
    
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
