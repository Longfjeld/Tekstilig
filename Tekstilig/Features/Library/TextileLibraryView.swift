import SwiftUI

struct TextileLibraryView: View {
    @State private var model = TextileLibraryModel()
    @State private var showNewTextile = false

    private var listItems: [TextileListItem] {
        model.textiles.map(TextileListItem.init)
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
                } else {
                    List(listItems) { item in
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
            .toolbar {
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

    init(_ textile: Textile) {
        id = textile.id
        name = textile.name
        category = textile.category
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
