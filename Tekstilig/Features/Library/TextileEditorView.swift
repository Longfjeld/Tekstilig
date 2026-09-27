import SwiftUI

struct TextileEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Textile) async throws -> Textile

    @State private var draft: Textile
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        textile: Textile?,
        onSave: @escaping (Textile) async throws -> Textile
    ) {
        self.onSave = onSave
        _draft = State(initialValue: textile ?? Textile.newDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Grunnopplysninger") {
                    TextField("Navn", text: $draft.name)

                    Picker("Kategori", selection: $draft.category) {
                        Text("Ikke valgt").tag("")
                        ForEach(Textile.categoryOptions, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }

                Section {
                    Text("Denne første produktversjonen lagrer bare navn og kategori. Resten av den avtalte datamodellen kobles på i senere steg uten å endre den logiske modellen.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(draft.cloudRecordName == nil ? "Nytt tekstil" : "Rediger tekstil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") {
                        save()
                    }
                    .disabled(isSaving || draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .interactiveDismissDisabled(isSaving)
            .alert(
                "Kunne ikke lagre",
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
