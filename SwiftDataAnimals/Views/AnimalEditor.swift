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
    @State private var selectedDiet = Animal.Diet.herbivorous
    @State private var selectedCategory: AnimalCategory?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \AnimalCategory.name) private var categories: [AnimalCategory]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("Select a category").tag(nil as AnimalCategory?)
                    ForEach(categories) { category in
                        Text(category.name).tag(category as AnimalCategory?)
                    }
                }
                
                Picker("Diet", selection: $selectedDiet) {
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
                    .disabled($selectedCategory.wrappedValue == nil)
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
                    selectedDiet = animal.diet
                    selectedCategory = animal.category
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
            animal.diet = selectedDiet
            animal.category = selectedCategory
        } else {
            // Add an animal.
            let newAnimal = Animal(name: name, diet: selectedDiet)
            newAnimal.category = selectedCategory
            modelContext.insert(newAnimal)
        }
    }
}

#Preview("Add animal") {
    ModelContainerPreview(ModelContainer.sample) {
        AnimalEditor(animal: nil)
    }
}

#Preview("Edit animal") {
    ModelContainerPreview(ModelContainer.sample) {
        AnimalEditor(animal: .kangaroo)
    }
}
