import SwiftUI

enum RuntimeEnvironment {
    // Set to true to demonstrate the app offline without touching Firestore.
    static let usesMockServices = false
}

@main
struct SiamSafeApp: App {
    var body: some Scene {
        WindowGroup { ContentView(usePreviewData: RuntimeEnvironment.usesMockServices) }
    }
}
