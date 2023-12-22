/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays the details of an animal.
*/

import SwiftUI
import SwiftData

struct AnimalDetailView: View {
    var animal: Animal?
    @State private var isEditing = false
    @State private var isDeleting = false
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationContext.self) private var navigationContext

    var body: some View {
        if let animal {
            AnimalDetailContentView(animal: animal)
                .navigationTitle("\(animal.name ?? "Animal")")
                .toolbar {
                    Button { isEditing = true } label: {
                        Label("Edit \(animal.name ?? "Animal")", systemImage: "pencil")
                            .help("Edit the animal")
                    }
                    
                    Button { isDeleting = true } label: {
                        Label("Delete \(animal.name ?? "Animal")", systemImage: "trash")
                            .help("Delete the animal")
                    }
                }
                .sheet(isPresented: $isEditing) {
                    AnimalEditor(animal: animal)
                }
                .alert("Delete \(animal.name ?? "Animal")?", isPresented: $isDeleting) {
                    Button("Yes, delete \(animal.name ?? "Animal")", role: .destructive) {
                        delete(animal)
                    }
                }
        } else {
            ContentUnavailableView("Select an animal", systemImage: "pawprint")
        }
    }
    
    private func delete(_ animal: Animal) {
        navigationContext.selectedAnimal = nil
        modelContext.delete(animal)
    }
}

private struct AnimalDetailContentView: View {
    let animal: Animal

    var body: some View {
        VStack {
            #if os(macOS)
            Text(animal.name ?? "Animal")
                .font(.title)
                .padding()
            #else
            EmptyView()
            #endif
            
            List {
                HStack {
                    Text("Category")
                    Spacer()
                    Text("\(animal.category?.name ?? "")")
                }
                HStack {
                    Text("Diet")
                    Spacer()
                    Text("\(animal.diet?.rawValue ?? "unknown")")
                }
//                HStack {
//                    Text("Extinct")
//                    Spacer()
//                    Text("\(animal.extinct ?? false ? "yes" : "no")")
//                }
            }
        }
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        AnimalDetailView(animal: .kangaroo)
            .environment(NavigationContext())
    }
}
