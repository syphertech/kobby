import SwiftUI
import Firebase

@main
struct kobbyApp: App {
    
    init() {
           FirebaseApp.configure()
       }
    // Initialize DataController for Core Data
    let dataController = DataController.shared

    // Initialize AudioReceiver with the managed object context from Core Data
    @StateObject private var audioReceiver = AudioReceiver(context: DataController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext) // Inject Core Data context
                .environmentObject(audioReceiver) // Inject AudioReceiver into environment
        }
    }
}
