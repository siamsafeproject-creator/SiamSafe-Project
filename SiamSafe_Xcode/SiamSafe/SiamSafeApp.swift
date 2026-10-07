import SwiftUI
import FirebaseCore

enum RuntimeEnvironment {
    static var isRunningInXcodePreview: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    // Only Canvas/Playgrounds use offline services. Simulator builds use the
    // same Firebase configuration, MapKit, and location services as devices.
    static var usesMockServices: Bool {
        return isRunningInXcodePreview
    }
}

@main
struct SiamSafeApp: App {

    init() {
        if !RuntimeEnvironment.usesMockServices {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
