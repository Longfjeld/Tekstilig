import SwiftUI

struct TextileMaterialEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (TextileMaterial) async throws -> TextileMaterial

    @State private var draft: TextileMaterial
    @State private var selectedOption: String
    @State private var customMaterial: String
    @State private var percentText: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        material: TextileMaterial?,
        textileID: String,
        onSave: @escaping (TextileMaterial) async throws -> TextileMaterial
    ) {
        let initial = material ?? TextileMaterial.newDraft(textileID: textileID)
        self.onSave = onSave
        _draft = State(initialValue: initial)

        if TextileMaterial.materialOptions.contains(initial.material), initial.material != "Annet" {
            _selectedOption = State(initialValue: initial.material)
            _customMaterial = State(initialValue: "")
        } else if initial.material.isEmpty {
            _selectedOption = State(initialValue: "")
            _customMaterial = State(initialValue: "")
        } else {
            _selectedOption = State(initialValue: "Annet")
            _customMaterial = State(initialValue: initial.material)
        }

        if let percent = initial.percent {
            _percentText = State(initialValue: String(percent))
        } else {
            _percentText = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Materiale") {
                    Picker("Fibertype", selection: $selectedOption) {
                        Text("Ikke valgt").tag("")
                        ForEach(TextileMaterial.materialOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }

                    if selectedOption == "Annet" {
                        TextField("Eget materialenavn", text: $customMaterial)
                    }

                    LabeledContent("Andel") {
                        HStack(spacing: 4) {
                            TextField("Valgfritt", text: $percentText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Text("Prosentandel er valgfri. Flere materialer kan registreres på samme tekstil, og summen trenger ikke være 100 %.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(draft.cloudRecordName == nil ? "Nytt materiale" : "Rediger materiale")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") { save() }
                        .disabled(!canSave)
                }
            }
            .interactiveDismissDisabled(isSaving)
            .alert(
                "Kunne ikke lagre materiale",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Ukjent feil")
            }
        }
    }

    private var resolvedMaterialName: String {
        if selectedOption == "Annet" {
            return customMaterial.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedOption
    }

    private var parsedPercent: Int64? {
        let trimmed = percentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Int64(trimmed)
    }

    private var canSave: Bool {
        guard !isSaving, !resolvedMaterialName.isEmpty else { return false }
        guard let percent = parsedPercent else {
            return percentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return (0...100).contains(percent)
    }

    private func save() {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        var candidate = draft
        candidate.material = resolvedMaterialName
        candidate.percent = parsedPercent

        Task {
            do {
                _ = try await onSave(candidate)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
