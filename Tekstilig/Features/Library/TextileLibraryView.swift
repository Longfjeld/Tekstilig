import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct TextileLibraryView: View {
    @State private var model = TextileLibraryModel()
    @State private var attributeIndex = TextileLibraryAttributeIndex()
    @State private var showNewTextile = false
    @State private var searchText = ""
    @State private var filters = TextileLibraryFilters()
    @State private var showFilters = false
    @State private var showAllTextiles = false

    private var listItems: [TextileListItem] {
        var items: [TextileListItem] = []
        items.reserveCapacity(model.textiles.count)

        for textile in model.textiles {
            items.append(
                TextileListItem(
                    id: textile.id,
                    textileID: textile.textileID,
                    name: textile.name,
                    category: textile.category,
                    locationArea: textile.locationArea,
                    locationShelf: textile.locationShelf,
                    locationContainer: textile.locationContainer,
                    notes: textile.notes,
                    weightGsm: textile.weightGsm,
                    stretchLevel: textile.stretch.level,
                    materials: attributeIndex.materials(for: textile.textileID),
                    colors: attributeIndex.colors(for: textile.textileID)
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

            if !filters.material.isEmpty,
               !item.materialNames.contains(where: {
                   $0.localizedCaseInsensitiveCompare(filters.material) == .orderedSame
               }) {
                return false
            }

            if !filters.colorGroup.isEmpty,
               !item.colorGroups.contains(where: {
                   $0.localizedCaseInsensitiveCompare(filters.colorGroup) == .orderedSame
               }) {
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

    private var hasActiveSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isLibraryListActive: Bool {
        showAllTextiles || hasActiveSearch || hasActiveFilter
    }

    private var recentTextiles: [Textile] {
        Array(
            model.textiles
                .sorted {
                    if $0.createdAt != $1.createdAt {
                        return $0.createdAt > $1.createdAt
                    }
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                .prefix(5)
        )
    }

    var onFindProject: () -> Void = { }

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
                        Text("Registrer det første tekstilet for å starte samlingen.")
                    } actions: {
                        Button("Registrer nytt stoff") {
                            showNewTextile = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if isLibraryListActive {
                    libraryListContent
                } else {
                    libraryHomeContent
                }
            }
            .navigationTitle("Tekstiler")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Søk i navn, materiale, farge og plassering"
            )
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
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

                    if showAllTextiles && !hasActiveSearch && !hasActiveFilter {
                        Button {
                            showAllTextiles = false
                        } label: {
                            Label("Oversikt", systemImage: "house")
                        }
                        .accessibilityLabel("Tilbake til oversikten")
                    }
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
                TextileLibraryFilterView(
                    filters: $filters,
                    attributeIndexIsLoading: attributeIndex.isLoading,
                    attributeIndexErrorMessage: attributeIndex.errorMessage
                )
            }
            .sheet(isPresented: $showNewTextile) {
                TextileEditorView(textile: nil) { candidate in
                    try await model.save(candidate)
                }
            }
            .task {
                await model.loadIfNeeded()
                await attributeIndex.loadIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var libraryListContent: some View {
        if filteredListItems.isEmpty {
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

                if hasActiveSearch {
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
                await attributeIndex.load()
            }
        }
    }

    private var libraryHomeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    showNewTextile = true
                } label: {
                    Label("Registrer nytt stoff", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if !recentTextiles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nylig registrert")
                            .font(.title3.weight(.semibold))

                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 12) {
                                ForEach(recentTextiles) { textile in
                                    NavigationLink {
                                        TextileDetailView(
                                            textileIdentity: textile.id,
                                            model: model
                                        )
                                    } label: {
                                        TextileRecentCard(textile: textile)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }

                Button {
                    showAllTextiles = true
                } label: {
                    Label("Vis alle tekstiler", systemImage: "square.grid.2x2")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    onFindProject()
                } label: {
                    Label("Finn til prosjekt", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .refreshable {
            await model.load()
            await attributeIndex.load()
        }
    }

}

private struct TextileLibraryFilters: Equatable {
    var category = ""
    var locationArea = ""
    var minimumWeight: Int?
    var maximumWeight: Int?
    var stretchLevel = ""
    var material = ""
    var colorGroup = ""

    var isActive: Bool {
        !category.isEmpty ||
        !locationArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        minimumWeight != nil ||
        maximumWeight != nil ||
        !stretchLevel.isEmpty ||
        !material.isEmpty ||
        !colorGroup.isEmpty
    }

    mutating func reset() {
        self = TextileLibraryFilters()
    }
}

private struct TextileLibraryFilterView: View {
    @Binding var filters: TextileLibraryFilters
    let attributeIndexIsLoading: Bool
    let attributeIndexErrorMessage: String?
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

                Section("Materiale") {
                    Picker("Materiale", selection: $filters.material) {
                        Text("Alle materialer").tag("")

                        ForEach(TextileMaterial.materialOptions, id: \.self) { material in
                            Text(material).tag(material)
                        }
                    }
                    .disabled(attributeIndexIsLoading || attributeIndexErrorMessage != nil)
                }

                Section("Farge") {
                    Picker("Fargegruppe", selection: $filters.colorGroup) {
                        Text("Alle farger").tag("")

                        ForEach(TextileColor.groupOptions, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .disabled(attributeIndexIsLoading || attributeIndexErrorMessage != nil)
                }

                if attributeIndexIsLoading {
                    Section {
                        ProgressView("Henter materiale og farge …")
                    }
                } else if let attributeIndexErrorMessage {
                    Section {
                        Text("Materiale- og fargefiltre kunne ikke oppdateres.")
                            .foregroundStyle(.secondary)
                        Text(attributeIndexErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
    let textileID: String
    let name: String
    let category: String
    let locationArea: String
    let locationShelf: String
    let locationContainer: String
    let notes: String
    let weightGsm: Int?
    let stretchLevel: String
    let materials: [TextileMaterial]
    let colors: [TextileColor]

    var materialNames: [String] {
        materials.map(\.material)
    }

    var colorGroups: [String] {
        colors.map(\.group)
    }

    var searchableText: String {
        var components = [
            name,
            category,
            locationArea,
            locationShelf,
            locationContainer,
            notes
        ]

        components.append(contentsOf: materials.map(\.material))
        components.append(contentsOf: colors.flatMap { [$0.group, $0.name] })

        return components
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

private struct TextileRecentCard: View {
    let textile: Textile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextileRecentThumbnail(textileID: textile.textileID)

            Text(textile.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 132)
        .accessibilityElement(children: .combine)
    }
}

private struct TextileRecentThumbnail: View {
    let textileID: String
    @State private var model = TextileImageModel()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.quaternary)

            if let data = model.primaryImage?.data {
                platformImage(data: data)
            } else if model.isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 132, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .task(id: textileID) {
            await model.loadIfNeeded(for: textileID)
        }
    }

    @ViewBuilder
    private func platformImage(data: Data) -> some View {
        #if canImport(UIKit)
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            imagePlaceholder
        }
        #elseif canImport(AppKit)
        if let image = NSImage(data: data) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
        } else {
            imagePlaceholder
        }
        #else
        imagePlaceholder
        #endif
    }

    private var imagePlaceholder: some View {
        Image(systemName: "photo")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    TextileLibraryView()
}
