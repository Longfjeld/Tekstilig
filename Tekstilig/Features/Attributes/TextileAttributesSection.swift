import SwiftUI

struct TextileAttributesSection: View {
    let textile: Textile

    @State private var model = TextileAttributesModel()
    @State private var editorRoute: AttributeEditorRoute?
    @State private var deletionTarget: AttributeDeletionTarget?

    var body: some View {
        Group {
            Section {
                if model.isLoading && model.materials.isEmpty && model.colors.isEmpty {
                    ProgressView("Henter materiale og farge …")
                } else if let errorMessage = model.errorMessage,
                          model.materials.isEmpty && model.colors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Kunne ikke hente materiale og farge", systemImage: "icloud.slash")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Button("Prøv igjen") {
                            Task {
                                await model.load(for: textile.textileID)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    if model.materials.isEmpty {
                        Text("Ingen materialer registrert")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.materials) { material in
                            Button {
                                editorRoute = .editMaterial(material)
                            } label: {
                                TextileMaterialRow(material: material)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Slett", role: .destructive) {
                                    deletionTarget = .material(material)
                                }
                            }
                        }
                    }

                    Button {
                        editorRoute = .newMaterial
                    } label: {
                        Label("Legg til materiale", systemImage: "plus")
                    }
                }
            } header: {
                Text("Materialer")
            }

            Section {
                if !model.isLoading || !model.materials.isEmpty || !model.colors.isEmpty {
                    if model.colors.isEmpty {
                        Text("Ingen farger registrert")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.colors) { color in
                            Button {
                                editorRoute = .editColor(color)
                            } label: {
                                TextileColorRow(color: color)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Slett", role: .destructive) {
                                    deletionTarget = .color(color)
                                }
                            }
                        }
                    }

                    Button {
                        editorRoute = .newColor
                    } label: {
                        Label("Legg til farge", systemImage: "plus")
                    }
                }
            } header: {
                Text("Farger")
            }
        }
        .task(id: textile.textileID) {
            await model.loadIfNeeded(for: textile.textileID)
        }
        .sheet(item: $editorRoute) { route in
            switch route {
            case .newMaterial:
                TextileMaterialEditorView(material: nil, textileID: textile.textileID) { candidate in
                    try await model.saveMaterial(candidate)
                }
            case .editMaterial(let material):
                TextileMaterialEditorView(material: material, textileID: textile.textileID) { candidate in
                    try await model.saveMaterial(candidate)
                }
            case .newColor:
                TextileColorEditorView(color: nil, textileID: textile.textileID) { candidate in
                    try await model.saveColor(candidate)
                }
            case .editColor(let color):
                TextileColorEditorView(color: color, textileID: textile.textileID) { candidate in
                    try await model.saveColor(candidate)
                }
            }
        }
        .confirmationDialog(
            "Slett registrering?",
            isPresented: Binding(
                get: { deletionTarget != nil },
                set: { if !$0 { deletionTarget = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Slett", role: .destructive) {
                deleteSelectedAttribute()
            }
            Button("Avbryt", role: .cancel) { }
        } message: {
            if let deletionTarget {
                Text(deletionTarget.message)
            }
        }
        .alert(
            "Kunne ikke endre materiale eller farge",
            isPresented: Binding(
                get: { model.errorMessage != nil && (!model.materials.isEmpty || !model.colors.isEmpty) },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "Ukjent feil")
        }
    }

    private func deleteSelectedAttribute() {
        guard let deletionTarget else { return }

        Task {
            do {
                switch deletionTarget {
                case .material(let material):
                    try await model.deleteMaterial(material)
                case .color(let color):
                    try await model.deleteColor(color)
                }
                self.deletionTarget = nil
            } catch {
                model.errorMessage = error.localizedDescription
                self.deletionTarget = nil
            }
        }
    }
}


private enum AttributeEditorRoute: Identifiable {
    case newMaterial
    case editMaterial(TextileMaterial)
    case newColor
    case editColor(TextileColor)

    var id: String {
        switch self {
        case .newMaterial: return "new-material"
        case .editMaterial(let material): return "edit-material-\(material.id)"
        case .newColor: return "new-color"
        case .editColor(let color): return "edit-color-\(color.id)"
        }
    }
}

private enum AttributeDeletionTarget: Identifiable {
    case material(TextileMaterial)
    case color(TextileColor)

    var id: String {
        switch self {
        case .material(let material): return "material-\(material.id)"
        case .color(let color): return "color-\(color.id)"
        }
    }

    var message: String {
        switch self {
        case .material(let material):
            return "\(material.material) slettes permanent fra dette tekstilet i CloudKit."
        case .color(let color):
            return "Fargen \(color.displayName) slettes permanent fra dette tekstilet i CloudKit."
        }
    }
}

private struct TextileMaterialRow: View {
    let material: TextileMaterial

    var body: some View {
        HStack {
            Text(material.material)
            Spacer()
            if let percent = material.percent {
                Text("\(percent) %")
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct TextileColorRow: View {
    let color: TextileColor

    var body: some View {
        HStack(spacing: 10) {
            if let swatch = Color(hexString: color.hex) {
                Circle()
                    .fill(swatch)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle().stroke(.secondary.opacity(0.35), lineWidth: 1)
                    }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(color.displayName)
                if !color.name.isEmpty && color.name != color.group {
                    Text(color.group)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if !color.hex.isEmpty {
                Text(color.hex)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

private extension TextileColor {
    var displayName: String {
        name.isEmpty ? group : name
    }
}

private extension Color {
    init?(hexString: String) {
        let value = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count == 7, value.first == "#" else { return nil }
        let hex = String(value.dropFirst())
        guard let rgb = UInt64(hex, radix: 16) else { return nil }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
