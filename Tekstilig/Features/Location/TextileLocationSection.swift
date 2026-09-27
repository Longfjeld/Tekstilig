import SwiftUI

struct TextileLocationSection: View {
    let textile: Textile
    let model: TextileLibraryModel

    @State private var showEditor = false

    var body: some View {
        Section {
            if textile.hasLocation {
                if !textile.locationArea.isEmpty {
                    LabeledContent("Område / rom", value: textile.locationArea)
                }
                if !textile.locationShelf.isEmpty {
                    LabeledContent("Hylle", value: textile.locationShelf)
                }
                if !textile.locationContainer.isEmpty {
                    LabeledContent("Beholder / kasse", value: textile.locationContainer)
                }
            } else {
                Text("Ingen plassering registrert")
                    .foregroundStyle(.secondary)
            }

            Button {
                showEditor = true
            } label: {
                Label(
                    textile.hasLocation ? "Rediger plassering" : "Legg til plassering",
                    systemImage: "shippingbox"
                )
            }
        } header: {
            Text("Plassering")
        }
        .sheet(isPresented: $showEditor) {
            TextileLocationEditorView(textile: textile) { candidate in
                try await model.save(candidate)
            }
        }
    }
}
