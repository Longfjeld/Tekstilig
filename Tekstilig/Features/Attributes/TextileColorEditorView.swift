import SwiftUI

struct TextileColorEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (TextileColor) async throws -> TextileColor

    @State private var draft: TextileColor
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        color: TextileColor?,
        textileID: String,
        onSave: @escaping (TextileColor) async throws -> TextileColor
    ) {
        self.onSave = onSave
        _draft = State(initialValue: color ?? TextileColor.newDraft(textileID: textileID))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Farge") {
                    Picker("Fargegruppe", selection: $draft.group) {
                        Text("Ikke valgt").tag("")
                        ForEach(TextileColor.groupOptions, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }

                    TextField("Beskrivende navn (valgfritt)", text: $draft.name)
                    TextField("Hex, f.eks. #273448 (valgfritt)", text: $draft.hex)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                Section {
                    Text("Fargegruppe brukes senere til robust filtrering. Navn og hex-verdi er valgfrie og gir en mer presis beskrivelse.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(draft.cloudRecordName == nil ? "Ny farge" : "Rediger farge")
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
                "Kunne ikke lagre farge",
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

    private var normalizedHex: String {
        let trimmed = draft.hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return "" }
        return trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
    }

    private var canSave: Bool {
        guard !isSaving,
              !draft.group.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        guard !normalizedHex.isEmpty else { return true }
        return normalizedHex.count == 7
            && normalizedHex.first == "#"
            && normalizedHex.dropFirst().allSatisfy { $0.isHexDigit }
    }

    private func save() {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        var candidate = draft
        candidate.group = draft.group.trimmingCharacters(in: .whitespacesAndNewlines)
        candidate.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        candidate.hex = normalizedHex

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
