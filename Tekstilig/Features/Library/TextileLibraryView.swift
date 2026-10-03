import SwiftUI

struct TextileLibraryView: View {
    @State private var model = TextileLibraryModel()
    @State private var showNewTextile = false
    @State private var searchText = ""
    @State private var selectedCategory = ""

    private var listItems: [TextileListItem] {
        var items: [TextileListItem] = []
        items.reserveCapacity(model.textiles.count)

        for textile in model.textiles {
            items.append(
                TextileListItem(
                    id: textile.id,
                    name: textile.name,
                    category: textile.category,
                    locationArea: textile.locationArea,
                    locationShelf: textile.locationShelf,
                    locationContainer: textile.locationContainer
                )
            )
        }

        return items
    }

    private var filteredListItems: [TextileListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return listItems.filter { item in
            let matchesCategory = selectedCategory.isEmpty ||
                item.category.localizedCaseInsensitiveCompare(selectedCategory) == .orderedSame

            guard matchesCategory else {
                return false
            }

            guard !query.isEmpty else {
                return true
            }

            return item.searchableText.localizedCaseInsensitiveContains(query)
        }
    }

    private var hasActiveFilter: Bool {
        !selectedCategory.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.isLoading && !model.hasLoaded {
                    ProgressView("Henter tekstiler …")
                } else if let errorMessage = model.errorMessage, model.textiles.isEmpty {
                    ContentUnavailableView {
                        Label("Kunne ikke hente tekstiler", systemImage: "icloud.slash")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Prøv igjen") {
                            Task {
                                await model.load()
                            }
                        }
                    }
                } else if model.textiles.isEmpty {
                    ContentUnavailableView {
                        Label("Ingen tekstiler ennå", systemImage: "square.grid.2x2")
                    } description: {
                        Text("Opprett det første tekstilet for å kontrollere den nye appflyten mot CloudKit.")
                    } actions: {
                        Button("Nytt tekstil") {
                            showNewTextile = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if filteredListItems.isEmpty {
                    ContentUnavailableView {
                        Label("Ingen treff", systemImage: "magnifyingglass")
                    } description: {
                        if hasActiveFilter {
                            Text("Ingen tekstiler passer søket og valgt kategori.")
                        } else {
                            Text("Ingen tekstiler passer søket.")
                        }
                    } actions: {
                        if hasActiveFilter {
                            Button("Nullstill kategori") {
                                selectedCategory = ""
                            }
                        }

                        if !searchText.isEmpty {
                            Button("Tøm søk") {
                                searchText = ""
                            }
                        }
                    }
                } else {
                    List(filteredListItems) { item in
                        NavigationLink {
                            TextileDetailView(
                                textileIdentity: item.id,
                                model: model
                            )
                        } label: {
                            TextileRow(
                                name: item.name,
                                category: item.category
                            )
                        }
                    }
                    .refreshable {
                        await model.load()
                    }
                }
            }
            .navigationTitle("Tekstiler")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Søk i navn, kategori og plassering"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Kategori", selection: $selectedCategory) {
                            Text("Alle kategorier").tag("")

                            ForEach(Textile.categoryOptions, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    } label: {
                        Label(
                            selectedCategory.isEmpty ? "Kategori" : selectedCategory,
                            systemImage: hasActiveFilter
                                ? "line.3.horizontal.decrease.circle.fill"
                                : "line.3.horizontal.decrease.circle"
                        )
                    }
                    .accessibilityLabel("Filtrer på kategori")
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewTextile = true
                    } label: {
                        Label("Nytt tekstil", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewTextile) {
                TextileEditorView(textile: nil) { candidate in
                    try await model.save(candidate)
                }
            }
            .task {
                await model.loadIfNeeded()
            }
        }
    }
}

private struct TextileListItem: Identifiable {
    let id: String
    let name: String
    let category: String
    let locationArea: String
    let locationShelf: String
    let locationContainer: String

    var searchableText: String {
        [
            name,
            category,
            locationArea,
            locationShelf,
            locationContainer
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }
}

private struct TextileRow: View {
    let name: String
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)

            Text(category.isEmpty ? "Kategori ikke registrert" : category)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TextileLibraryView()
}
