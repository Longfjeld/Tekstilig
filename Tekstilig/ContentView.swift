import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .textiles

    var body: some View {
        TabView(selection: $selectedTab) {
            TextileLibraryView {
                selectedTab = .projectSearch
            }
                .tag(AppTab.textiles)
                .tabItem {
                    Label("Tekstiler", systemImage: "square.grid.2x2")
                }

            ProjectSearchView(isActive: selectedTab == .projectSearch)
                .tag(AppTab.projectSearch)
                .tabItem {
                    Label("Finn til prosjekt", systemImage: "magnifyingglass")
                }

            #if DEBUG
            DeveloperDiagnosticsView()
                .tag(AppTab.development)
                .tabItem {
                    Label("Utvikling", systemImage: "wrench.and.screwdriver")
                }
            #endif
        }
    }
}

private enum AppTab: Hashable {
    case textiles
    case projectSearch
    #if DEBUG
    case development
    #endif
}

#Preview {
    ContentView()
}
