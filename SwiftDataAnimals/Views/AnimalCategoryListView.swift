/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that displays a list of animal categories.
*/

import SwiftUI
import SwiftData

struct AnimalCategoryListView: View {
    @EnvironmentObject() private var navigationContext: NavigationContext
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AnimalCategory.name) private var animalCategories: [AnimalCategory]
    @State private var isReloadPresented = false

    var body: some View {
        List(selection: $navigationContext.selectedAnimalCategoryName) {
            #if os(macOS)
            Section(navigationContext.sidebarTitle) {
                ListCategories(animalCategories: animalCategories)
            }
            #else
            ListCategories(animalCategories: animalCategories)
            #endif
        }
        .alert("Reload Sample Data?", isPresented: $isReloadPresented) {
            Button("Yes, reload sample data", role: .destructive) {
                reloadSampleData()
            }
        } message: {
            Text("Reloading the sample data deletes all changes to the current data.")
        }
        .toolbar {
            Button {
                isReloadPresented = true
            } label: {
                Label("", systemImage: "arrow.clockwise")
                    .help("Reload sample data")
            }
        }
        .task {
            if animalCategories.isEmpty {
                AnimalCategory.insertSampleData(modelContext: modelContext)
            }
        }
    }
    
    @MainActor
    private func reloadSampleData() {
        navigationContext.selectedAnimal = nil
        navigationContext.selectedAnimalCategoryName = nil
        AnimalCategory.reloadSampleData(modelContext: modelContext)
    }
}

private struct ListCategories: View {
    var animalCategories: [AnimalCategory]
    
    var body: some View {
        ForEach(animalCategories) { animalCategory in
            NavigationLink(animalCategory.name, value: animalCategory.name)
        }
    }
}

#Preview("AnimalCategoryListView") {
    ModelContainerPreview(ModelContainer.sample) {
        NavigationStack {
            AnimalCategoryListView()
        }
        .environmentObject(NavigationContext())
    }
}

#Preview("ListCategories") {
    ModelContainerPreview(ModelContainer.sample) {
        NavigationStack {
            List {
                ListCategories(animalCategories: [.amphibian, .bird])
            }
        }
        .environmentObject(NavigationContext())
    }
}
