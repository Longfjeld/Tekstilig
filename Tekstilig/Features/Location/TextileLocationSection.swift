import SwiftUI

struct TextileLocationSection: View {
    let textile: Textile
    let onEditLocation: () -> Void

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

            Button(action: onEditLocation) {
                Label(
                    textile.hasLocation ? "Rediger plassering" : "Legg til plassering",
                    systemImage: "shippingbox"
                )
            }
        } header: {
            Text("Plassering")
        }
    }
}
