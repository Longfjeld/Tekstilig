import SwiftUI

struct PieceEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Piece) async throws -> Piece

    @State private var draft: Piece
    @State private var hasReservation: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        piece: Piece?,
        textileID: String,
        onSave: @escaping (Piece) async throws -> Piece
    ) {
        let initialPiece = piece ?? Piece.newDraft(textileID: textileID)
        self.onSave = onSave
        _draft = State(initialValue: initialPiece)
        _hasReservation = State(initialValue: initialPiece.isReserved)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Størrelse") {
                    TextField("Lengde (cm)", value: $draft.lengthCm, format: .number)
                        .keyboardType(.numberPad)

                    TextField("Bredde (cm)", value: $draft.widthCm, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("Reservasjon") {
                    Toggle("Reserver del av stykket", isOn: $hasReservation)

                    if hasReservation {
                        TextField(
                            "Reservert lengde (cm)",
                            value: $draft.reservedLengthCm,
                            format: .number
                        )
                        .keyboardType(.numberPad)

                        TextField("Prosjekt", text: $draft.project)
                    }
                }

                if draft.lengthCm > 0 {
                    Section("Tilgjengelig") {
                        LabeledContent(
                            "Tilgjengelig lengde",
                            value: "\(effectiveAvailableLengthCm) cm"
                        )
                    }
                }
            }
            .navigationTitle(draft.cloudRecordName == nil ? "Nytt stoffstykke" : "Rediger stoffstykke")
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
                    .disabled(!canSave)
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

    private var effectiveReservedLengthCm: Int64 {
        hasReservation ? draft.reservedLengthCm : 0
    }

    private var effectiveAvailableLengthCm: Int64 {
        max(0, draft.lengthCm - effectiveReservedLengthCm)
    }

    private var canSave: Bool {
        guard !isSaving,
              draft.lengthCm > 0,
              draft.widthCm > 0 else {
            return false
        }

        guard hasReservation else {
            return true
        }

        return draft.reservedLengthCm > 0
            && draft.reservedLengthCm <= draft.lengthCm
            && !draft.project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        var candidate = draft
        if !hasReservation {
            candidate.reservedLengthCm = 0
            candidate.project = ""
        }

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
