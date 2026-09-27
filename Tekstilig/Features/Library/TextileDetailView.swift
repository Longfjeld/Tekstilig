import SwiftUI

struct TextileDetailView: View {
    let textileIdentity: String
    let model: TextileLibraryModel

    @State private var showEditor = false

    private var textile: Textile? {
        model.textile(withIdentity: textileIdentity)
    }

    var body: some View {
        Group {
            if let textile {
                List {
                    Section("Tekstil") {
                        LabeledContent("Navn", value: textile.name)
                        LabeledContent(
                            "Kategori",
                            value: textile.category.isEmpty ? "Ikke registrert" : textile.category
                        )
                    }

                    Section("CloudKit") {
                        LabeledContent("Tekstilig-ID", value: textile.textileID)

                        if let cloudRecordName = textile.cloudRecordName {
                            LabeledContent("Record name", value: cloudRecordName)
                        }
                    }

                    Section("Status") {
                        LabeledContent("Opprettet") {
                            Text(textile.createdAt, format: .dateTime.day().month().year())
                        }
                        LabeledContent("Sist endret") {
                            Text(textile.updatedAt, format: .dateTime.day().month().year().hour().minute())
                        }
                    }
                }
                .navigationTitle(textile.name)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Rediger") {
                            showEditor = true
                        }
                    }
                }
                .sheet(isPresented: $showEditor) {
                    TextileEditorView(textile: textile) { candidate in
                        try await model.save(candidate)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Tekstilet finnes ikke",
                    systemImage: "questionmark.folder",
                    description: Text("Oppdater tekstilbiblioteket og prøv igjen.")
                )
            }
        }
    }
}
