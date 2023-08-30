/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a three-column split view.
*/

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var navigationContext = NavigationContext()

    var body: some View {
        ThreeColumnContentView()
            .environmentObject(navigationContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(try! ModelContainer.sample())
}
