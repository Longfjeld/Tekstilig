import SwiftUI

struct TextileLibraryView: View {
    @State private var model = TextileLibraryModel()
    @State private var showNewTextile = false
    @State private var searchText = ""
    @State private var filters = TextileLibraryFilters()
    @State private var showFilters = false

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
                    locationContainer: textile.locationContainer,
                    weightGsm: textile.weightGsm,
                    stretchLevel: textile.stretch.level
                )
            )
        }

        return items
    }

    private var filteredListItems: [TextileListItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let areaQuery = filters.locationArea.trimmingCharacters(in: .whitespacesAndNewlines)

        return listItems.filter { item in
            if !filters.category.isEmpty,
               item.category.localizedCaseInsensitiveCompare(filters.category) != .orderedSame {
                return false
            }

            if !areaQuery.isEmpty,
               !item.locationArea.localizedCaseInsensitiveContains(areaQuery) {
                return false
            }

            if let minimumWeight = filters.minimumWeight {
                guard let weight = item.weightGsm, weight >= minimumWeight else {
                    return false
                }
            }

            if let maximumWeight = filters.maximumWeight {
                guard let weight = item.weightGsm, weight <= maximumWeight else {
                    return false
                }
            }

            if !filters.stretchLevel.isEmpty,
               item.stretchLevel != filters.stretchLevel {
                return false
            }

            guard !query.isEmpty else {
                return true
            }

            return item.searchableText.localizedCaseInsensitiveContains(query)
        }
    }

    private var hasActiveFilter: Bool {
        filters.isActive
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
                            Text("Ingen tekstiler passer søket og valgte filtre.")
                        } else {
                            Text("Ingen tekstiler passer søket.")
                        }
                    } actions: {
                        if hasActiveFilter {
                            Button("Nullstill filtre") {
                                filters.reset()
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
                    Button {
                        showFilters = true
                    } label: {
                        Label(
                            "Filtre",
                            systemImage: hasActiveFilter
                                ? "line.3.horizontal.decrease.circle.fill"
                                : "line.3.horizontal.decrease.circle"
                        )
                    }
                    .accessibilityLabel(hasActiveFilter ? "Filtre, aktive filtre" : "Filtre")
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewTextile = true
                    } label: {
                        Label("Nytt tekstil", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                TextileLibraryFilterView(filters: $filters)
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

private struct TextileLibraryFilters: Equatable {
    var category = ""
    var locationArea = ""
    var minimumWeight: Int?
    var maximumWeight: Int?
    var stretchLevel = ""

    var isActive: Bool {
        !category.isEmpty ||
        !locationArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        minimumWeight != nil ||
        maximumWeight != nil ||
        !stretchLevel.isEmpty
    }

    mutating func reset() {
        self = TextileLibraryFilters()
    }
}

private struct TextileLibraryFilterView: View {
    @Binding var filters: TextileLibraryFilters
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Kategori") {
                    Picker("Kategori", selection: $filters.category) {
                        Text("Alle kategorier").tag("")

                        ForEach(Textile.categoryOptions, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }

                Section("Plassering") {
                    TextField("Område", text: $filters.locationArea)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    TextField("Minimum g/m²", value: $filters.minimumWeight, format: .number)
                        .keyboardType(.numberPad)

                    TextField("Maksimum g/m²", value: $filters.maximumWeight, format: .number)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Vekt")
                } footer: {
                    Text("Tekstiler uten registrert vekt skjules når et vektfilter er aktivt.")
                }

                Section("Elastisitet") {
                    Picker("Nivå", selection: $filters.stretchLevel) {
                        Text("Alle nivåer").tag("")
                        Text("Ingen").tag("none")
                        Text("Lav").tag("low")
                        Text("Middels").tag("medium")
                        Text("Høy").tag("high")
                    }
                }

                if filters.isActive {
                    Section {
                        Button("Nullstill alle filtre", role: .destructive) {
                            filters.reset()
                        }
                    }
                }
            }
            .navigationTitle("Filtre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") {
                        dismiss()
                    }
                }
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
    let weightGsm: Int?
    let stretchLevel: String

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
