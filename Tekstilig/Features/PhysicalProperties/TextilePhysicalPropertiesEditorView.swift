import SwiftUI

struct TextilePhysicalPropertiesEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Textile) async throws -> Textile

    @State private var draft: Textile
    @State private var weightText: String
    @State private var stretchPercentText: String
    @State private var shrinkLengthText: String
    @State private var shrinkWidthText: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        textile: Textile,
        onSave: @escaping (Textile) async throws -> Textile
    ) {
        self.onSave = onSave
        _draft = State(initialValue: textile)
        _weightText = State(initialValue: textile.weightGsm.map(String.init) ?? "")
        _stretchPercentText = State(initialValue: textile.stretch.percent.map(String.init) ?? "")
        _shrinkLengthText = State(initialValue: textile.shrinkage.lengthPercent.map(String.init) ?? "")
        _shrinkWidthText = State(initialValue: textile.shrinkage.widthPercent.map(String.init) ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vekt") {
                    TextField("g/m²", text: $weightText)
                        .keyboardType(.numberPad)
                } footer: {
                    Text("La feltet stå tomt dersom vekt ikke er kjent.")
                }

                Section("Elastisitet") {
                    Picker("Grad", selection: $draft.stretch.level) {
                        Text("Ikke registrert").tag("")
                        Text("Ingen").tag("none")
                        Text("Lav").tag("low")
                        Text("Middels").tag("medium")
                        Text("Høy").tag("high")
                    }

                    if !draft.stretch.level.isEmpty && draft.stretch.level != "none" {
                        Picker("Retning", selection: $draft.stretch.direction) {
                            Text("Ikke registrert").tag("")
                            Text("Lengde").tag("length")
                            Text("Bredde").tag("width")
                            Text("Begge").tag("both")
                            Text("Ikke relevant").tag("notApplicable")
                        }

                        TextField("Prosent, valgfritt", text: $stretchPercentText)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Krymp") {
                    TextField("Lengde i prosent", text: $shrinkLengthText)
                        .keyboardType(.numberPad)
                    TextField("Bredde i prosent", text: $shrinkWidthText)
                        .keyboardType(.numberPad)
                    TextField(
                        "Merknad, for eksempel etter vask på 40 °C",
                        text: $draft.shrinkage.note,
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }
            }
            .navigationTitle("Fysiske egenskaper")
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
                "Kunne ikke lagre fysiske egenskaper",
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

        do {
            draft.weightGsm = try parseOptionalInt(weightText, field: "Vekt", range: 1...5000)

            if draft.stretch.level == "none" || draft.stretch.level.isEmpty {
                draft.stretch.percent = nil
                stretchPercentText = ""
            } else {
                draft.stretch.percent = try parseOptionalInt(
                    stretchPercentText,
                    field: "Elastisitet",
                    range: 0...100
                )
            }

            draft.shrinkage.lengthPercent = try parseOptionalInt(
                shrinkLengthText,
                field: "Krymp i lengderetning",
                range: 0...100
            )
            draft.shrinkage.widthPercent = try parseOptionalInt(
                shrinkWidthText,
                field: "Krymp i bredderetning",
                range: 0...100
            )

            draft.stretch = draft.stretch.normalized()
            draft.shrinkage = draft.shrinkage.normalized()
        } catch {
            errorMessage = error.localizedDescription
            return
        }

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

    private func parseOptionalInt(
        _ rawValue: String,
        field: String,
        range: ClosedRange<Int>
    ) throws -> Int? {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        guard let value = Int(normalized), range.contains(value) else {
            throw TextilePhysicalPropertiesEditorError.invalidNumber(
                field: field,
                minimum: range.lowerBound,
                maximum: range.upperBound
            )
        }
        return value
    }
}

private enum TextilePhysicalPropertiesEditorError: LocalizedError {
    case invalidNumber(field: String, minimum: Int, maximum: Int)

    var errorDescription: String? {
        switch self {
        case .invalidNumber(let field, let minimum, let maximum):
            return "\(field) må være et heltall fra \(minimum) til \(maximum), eller stå tomt."
        }
    }
}
