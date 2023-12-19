/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main app, which creates a scene that shows the content view and sets the
 model container for the app.
*/

import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.example.apple-samplecode.SwiftDataAnimals", category: "App")

@main
struct SwiftDataAnimalsApp: App {
    
    var container: ModelContainer
    
    init() {
        self.container = setupModelContainer()
    }
                                  
    var body: some Scene {
        WindowGroup() {
            ContentView()
        }
        .modelContainer(container)
        #if os(macOS)
        .commands {
            SidebarCommands()
        }
        #endif
    }
}
