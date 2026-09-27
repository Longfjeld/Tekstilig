import SwiftUI

struct ContentView: View {
    var body: some View {
        #if DEBUG
        TabView {
            TextileLibraryView()
                .tabItem {
                    Label("Tekstiler", systemImage: "square.grid.2x2")
                }

            DeveloperDiagnosticsView()
                .tabItem {
                    Label("Utvikling", systemImage: "wrench.and.screwdriver")
                }
        }
        #else
        TextileLibraryView()
        #endif
    }
}

#Preview {
    ContentView()
}
