import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TextileLibraryView()
                .tabItem {
                    Label("Tekstiler", systemImage: "square.grid.2x2")
                }

            ProjectSearchView()
                .tabItem {
                    Label("Finn til prosjekt", systemImage: "magnifyingglass")
                }

            #if DEBUG
            DeveloperDiagnosticsView()
                .tabItem {
                    Label("Utvikling", systemImage: "wrench.and.screwdriver")
                }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
