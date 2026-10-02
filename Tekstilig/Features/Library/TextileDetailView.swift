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
        VStack(alignment: .leading, spacing: 12) {
            if let textileSnapshot {
                Text(textileSnapshot.name)
                    .font(.title2)

                Text(textileSnapshot.category.isEmpty ? "Ikke registrert" : textileSnapshot.category)
                    .foregroundStyle(.secondary)
            } else {
                Text("Tekstilet finnes ikke")
            }
        }
        .padding()
        .navigationTitle("Tekstil")
    }
}
