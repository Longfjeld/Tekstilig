import SwiftUI

struct TextileCareEditorView: View {
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
                Section("Vask") {
                    Picker("Vask", selection: washModeBinding) {
                        Text("Ikke registrert").tag("")
                        Text("Vask tillatt").tag("allowed")
                        Text("Skal ikke vaskes").tag("notAllowed")
                    }

                    if draft.care.washAllowed == true {
                        Picker("Temperatur", selection: $draft.care.washTemperatureC) {
                            Text("Ikke registrert").tag(Int?.none)
                            ForEach([20, 30, 40, 60, 90], id: \.self) { value in
                                Text("\(value) °C").tag(Int?.some(value))
                            }
                        }

                        Picker("Program", selection: $draft.care.washCycle) {
                            Text("Ikke registrert").tag("")
                            Text("Normalprogram").tag("normal")
                            Text("Skånsomt program").tag("gentle")
                            Text("Svært skånsomt program").tag("veryGentle")
                        }
                    }
                }

                Section("Bleking") {
                    Picker("Bleking", selection: $draft.care.bleach) {
                        Text("Ikke registrert").tag("")
                        Text("Tillatt").tag("allowed")
                        Text("Kun oksygen-/klorfri bleking").tag("nonChlorine")
                        Text("Ikke tillatt").tag("notAllowed")
                    }
                }

                Section("Tørking") {
                    Picker("Tørketrommel", selection: $draft.care.tumbleDry) {
                        Text("Ikke registrert").tag("")
                        Text("Lav temperatur").tag("low")
                        Text("Normal temperatur").tag("normal")
                        Text("Ikke tillatt").tag("notAllowed")
                    }

                    Picker("Annen tørking", selection: $draft.care.drying) {
                        Text("Ikke registrert").tag("")
                        Text("Hengetørkes").tag("line")
                        Text("Drypptørkes").tag("drip")
                        Text("Flattørkes").tag("flat")
                        Text("Tørkes i skyggen").tag("shade")
                    }
                }

                Section("Stryking") {
                    Picker("Stryking", selection: $draft.care.iron) {
                        Text("Ikke registrert").tag("")
                        Text("Lav temperatur").tag("low")
                        Text("Middels temperatur").tag("medium")
                        Text("Høy temperatur").tag("high")
                        Text("Ikke tillatt").tag("notAllowed")
                    }
                }

                Section("Rens") {
                    Picker("Rens", selection: $draft.care.dryClean) {
                        Text("Ikke registrert").tag("")
                        Text("P").tag("P")
                        Text("F").tag("F")
                        Text("W – våtrens").tag("W")
                        Text("Ikke tillatt").tag("notAllowed")
                    }
                }

                Section("Merknad") {
                    TextField(
                        "Ekstra informasjon om vedlikehold",
                        text: $draft.care.notes,
                        axis: .vertical
                    )
                    .lineLimit(2...6)
                }
            }
            .navigationTitle("Vedlikehold")
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
                "Kunne ikke lagre vedlikehold",
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

    private var washModeBinding: Binding<String> {
        Binding(
            get: {
                guard let allowed = draft.care.washAllowed else { return "" }
                return allowed ? "allowed" : "notAllowed"
            },
            set: { value in
                switch value {
                case "allowed":
                    draft.care.washAllowed = true
                case "notAllowed":
                    draft.care.washAllowed = false
                    draft.care.washTemperatureC = nil
                    draft.care.washCycle = ""
                default:
                    draft.care.washAllowed = nil
                    draft.care.washTemperatureC = nil
                    draft.care.washCycle = ""
                }
            }
        )
    }

    private func save() {
        guard !isSaving else { return }

        isSaving = true
        errorMessage = nil
        draft.care = draft.care.normalized()

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
