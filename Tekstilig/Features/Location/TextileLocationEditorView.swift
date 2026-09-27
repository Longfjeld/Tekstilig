import SwiftUI

struct TextileLocationEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Textile) async throws -> Textile

    @State private var draft: Textile
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        textile: Textile,
        onSave: @escaping (Textile) async throws -> Textile
    ) {
        self.onSave = onSave
        _draft = State(initialValue: textile)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plassering") {
                    TextField("Område / rom", text: $draft.locationArea)
                        .textInputAutocapitalization(.sentences)

                    TextField("Hylle", text: $draft.locationShelf)
                        .textInputAutocapitalization(.sentences)

                    TextField("Beholder / kasse", text: $draft.locationContainer)
                        .textInputAutocapitalization(.sentences)
                }

                Section {
                    Text("Alle tre feltene er valgfrie. Eksempel: Arbeidsrom → Hylle 3 → Kasse B.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Rediger plassering")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                        .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") { save() }
                        .disabled(isSaving)
                }
            }
            .interactiveDismissDisabled(isSaving)
            .alert(
                "Kunne ikke lagre plassering",
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

    private func save() {
        guard !isSaving else { return }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                _ = try await onSave(draft)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
