import Foundation
import SwiftUI

@main
struct TekstiligApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS) && DEBUG
            if ProcessInfo.processInfo.arguments.contains("--diagnostic-cloudkit-development-read") {
                DevelopmentIdentityReadDiagnosticView()
            } else if ProcessInfo.processInfo.arguments.contains("--diagnostic-local-cloudkit-environment") {
                LocalCloudKitEnvironmentDiagnosticView()
            } else {
                ContentView()
            }
            #else
            ContentView()
            #endif
        }
    }
}
