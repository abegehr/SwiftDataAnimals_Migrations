/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays a data entry form for editing information about an animal.
*/

import SwiftUI
import SwiftData

struct AnimalEditor: View {
    let animal: Animal?
    
    private var editorTitle: String {
        animal == nil ? "Add Animal" : "Edit Animal"
    }
    
    @State private var name = ""
    @State private var diet = Animal.Diet.herbivorous
    @State private var category: AnimalCategory?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject() private var navigationContext: NavigationContext
    
    @Query(sort: \AnimalCategory.name) private var categories: [AnimalCategory]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Picker("Category", selection: $category) {
                    Text("Select a category").tag(nil as AnimalCategory?)
                    ForEach(categories) { category in
                        Text(category.name).tag(category as AnimalCategory?)
                    }
                }
                
                Picker("Diet", selection: $diet) {
                    ForEach(Animal.Diet.allCases, id: \.self) { diet in
                        Text(diet.rawValue).tag(diet)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    // Require a category to save changes.
                    .disabled($category.wrappedValue == nil)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let animal {
                    // Edit the incoming animal.
                    name = animal.name
                    diet = animal.diet
                    category = animal.category
                }
            }
            #if os(macOS)
            .padding()
            #endif
        }
    }
    
    private func save() {
        if let animal {
            // Edit the animal.
            animal.name = name
            animal.diet = diet
            animal.category = category
        } else {
            // Add an animal.
            let newAnimal = Animal(name: name, diet: diet)
            newAnimal.category = category
            modelContext.insert(newAnimal)
        }
    }
}

#Preview("Add animal") {
    ModelContainerPreview(ModelContainer.sample) {
        AnimalEditor(animal: nil)
            .environmentObject(NavigationContext())
    }
}

#Preview("Edit animal") {
    ModelContainerPreview(ModelContainer.sample) {
        AnimalEditor(animal: .kangaroo)
            .environmentObject(NavigationContext())
    }
}
