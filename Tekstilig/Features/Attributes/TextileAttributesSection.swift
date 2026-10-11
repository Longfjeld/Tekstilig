import SwiftUI

struct TextileAttributesSection: View {
    let textile: Textile
    let model: TextileAttributesModel
    let onAddMaterial: () -> Void
    let onEditMaterial: (TextileMaterial) -> Void
    let onAddColor: () -> Void
    let onEditColor: (TextileColor) -> Void

    @State private var deletionTarget: AttributeDeletionTarget?

    var body: some View {
        Group {
            if hasSharedLoadingState {
                Section {
                    ProgressView("Henter materiale og farge …")
                } header: {
                    Text("Materialer og farger")
                }
            } else if hasSharedLoadFailure {
                Section {
                    loadErrorView(
                        title: "Kunne ikke hente materiale og farge",
                        message: model.materialLoadErrorMessage ?? model.colorLoadErrorMessage ?? "Ukjent feil",
                        retry: {
                            Task {
                                await model.load(for: textile.textileID)
                            }
                        }
                    )
                } header: {
                    Text("Materialer og farger")
                }
            } else {
                Section {
                    if model.isLoading && model.materials.isEmpty && model.materialLoadErrorMessage == nil {
                        ProgressView("Henter materialer …")
                    } else if let errorMessage = model.materialLoadErrorMessage, model.materials.isEmpty {
                        loadErrorView(
                            title: "Kunne ikke hente materialer",
                            message: errorMessage,
                            retry: {
                                Task {
                                    await model.retryMaterials(for: textile.textileID)
                                }
                            }
                        )
                    } else {
                        if model.materials.isEmpty {
                            Text("Ingen materialer registrert")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(model.materials) { material in
                                Button {
                                    onEditMaterial(material)
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
                            onAddMaterial()
                        } label: {
                            Label("Legg til materiale", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Materialer")
                }

                Section {
                    if model.isLoading && model.colors.isEmpty && model.colorLoadErrorMessage == nil {
                        ProgressView("Henter farger …")
                    } else if let errorMessage = model.colorLoadErrorMessage, model.colors.isEmpty {
                        loadErrorView(
                            title: "Kunne ikke hente farger",
                            message: errorMessage,
                            retry: {
                                Task {
                                    await model.retryColors(for: textile.textileID)
                                }
                            }
                        )
                    } else {
                        if model.colors.isEmpty {
                            Text("Ingen farger registrert")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(model.colors) { color in
                                Button {
                                    onEditColor(color)
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
                            onAddColor()
                        } label: {
                            Label("Legg til farge", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Farger")
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
                get: { model.mutationErrorMessage != nil },
                set: { if !$0 { model.mutationErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.mutationErrorMessage ?? "Ukjent feil")
        }
    }

    private var hasSharedLoadingState: Bool {
        model.isLoading &&
        model.materials.isEmpty &&
        model.colors.isEmpty &&
        model.materialLoadErrorMessage == nil &&
        model.colorLoadErrorMessage == nil
    }

    private var hasSharedLoadFailure: Bool {
        model.materialLoadErrorMessage != nil &&
        model.colorLoadErrorMessage != nil &&
        model.materials.isEmpty &&
        model.colors.isEmpty
    }

    @ViewBuilder
    private func loadErrorView(
        title: String,
        message: String,
        retry: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "icloud.slash")
                .font(.headline)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
            Button("Prøv igjen", action: retry)
        }
        .padding(.vertical, 4)
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
                model.mutationErrorMessage = TextileAttributesModel.description(for: error)
                self.deletionTarget = nil
            }
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
