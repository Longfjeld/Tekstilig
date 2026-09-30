import SwiftUI

struct TextileDetailView: View {
    let textileIdentity: String
    let model: TextileLibraryModel

    @State private var textileSnapshot: Textile?

    init(textileIdentity: String, model: TextileLibraryModel) {
        self.textileIdentity = textileIdentity
        self.model = model
        _textileSnapshot = State(initialValue: model.textile(withIdentity: textileIdentity))
    }

    var body: some View {
        Group {
            if let textile = textileSnapshot {
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
                }
                .navigationTitle(textile.name)
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
