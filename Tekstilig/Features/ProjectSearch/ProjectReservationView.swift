import SwiftUI

struct ProjectReservationView: View {
    @Environment(\.dismiss) private var dismiss

    let piece: Piece
    let suggestedLengthCm: Int64?
    let onSaved: () async -> Void

    @State private var model = PieceInventoryModel()
    @State private var reservedLengthCm: Int64?
    @State private var project = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    init(
        piece: Piece,
        suggestedLengthCm: Int64?,
        onSaved: @escaping () async -> Void
    ) {
        self.piece = piece
        self.suggestedLengthCm = suggestedLengthCm
        self.onSaved = onSaved

        let initialLength: Int64?
        if piece.reservedLengthCm > 0 {
            initialLength = piece.reservedLengthCm
        } else if let suggestedLengthCm, suggestedLengthCm > 0 {
            initialLength = min(suggestedLengthCm, piece.lengthCm)
        } else {
            initialLength = nil
        }

        _reservedLengthCm = State(initialValue: initialLength)
        _project = State(initialValue: piece.project)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stoffstykke") {
                    LabeledContent("Total lengde", value: "\(piece.lengthCm) cm")
                    LabeledContent("Bredde", value: "\(piece.widthCm) cm")
                    LabeledContent("Tilgjengelig nå", value: "\(piece.availableLengthCm) cm")
                }

                Section {
                    LabeledContent("Reservert lengde") {
                        TextField("cm", value: $reservedLengthCm, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .length)
                    }

                    TextField("Prosjekt", text: $project)
                        .focused($focusedField, equals: .project)
                } header: {
                    Text("Reservasjon")
                } footer: {
                    Text("Denne første versjonen lagrer én reservasjon per stoffstykke. En eksisterende reservasjon redigeres i stedet for å opprette en ny parallell reservasjon.")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(piece.isReserved ? "Endre reservasjon" : "Reserver stykke")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                        .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") { save() }
                        .disabled(!canSave)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Ferdig") { focusedField = nil }
                }
            }
            .interactiveDismissDisabled(isSaving)
            .alert(
                "Kunne ikke lagre reservasjon",
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

    private var normalizedProject: String {
        project.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        guard !isSaving,
              let reservedLengthCm,
              reservedLengthCm > 0,
              reservedLengthCm <= piece.lengthCm,
              !normalizedProject.isEmpty else {
            return false
        }
        return true
    }

    private func save() {
        guard canSave, let reservedLengthCm else { return }

        focusedField = nil
        isSaving = true
        errorMessage = nil

        var candidate = piece
        candidate.reservedLengthCm = reservedLengthCm
        candidate.project = normalizedProject

        Task {
            do {
                _ = try await model.save(candidate)
                await onSaved()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

private enum Field: Hashable {
    case length
    case project
}
