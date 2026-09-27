import SwiftUI

struct TextileLibraryView: View {
    @State private var model = TextileLibraryModel()
    @State private var showNewTextile = false

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
                    List(model.textiles) { textile in
                        NavigationLink {
                            TextileDetailView(
                                textileID: textile.textileID,
                                model: model
                            )
                        } label: {
                            TextileRow(textile: textile)
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

private struct TextileRow: View {
    let textile: Textile

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(textile.name)
                .font(.headline)

            Text(textile.category.isEmpty ? "Kategori ikke registrert" : textile.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TextileLibraryView()
}
