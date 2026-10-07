import SwiftUI

struct TextileDetailView: View {
    let textileIdentity: String
    let model: TextileLibraryModel

    @State private var textileSnapshot: Textile?
    @State private var attributesModel = TextileAttributesModel()
    @State private var pieceModel = PieceInventoryModel()
    @State private var isEditingBasics = false
    @State private var isEditingMaterial = false
    @State private var materialToEdit: TextileMaterial?
    @State private var isEditingColor = false
    @State private var colorToEdit: TextileColor?
    @State private var isEditingPhysicalProperties = false
    @State private var isEditingCare = false
    @State private var isEditingLocation = false
    @State private var isAddingPiece = false
    @State private var editingPiece: Piece?
    @State private var piecePendingDeletion: Piece?

    init(textileIdentity: String, model: TextileLibraryModel) {
        self.textileIdentity = textileIdentity
        self.model = model
        _textileSnapshot = State(initialValue: model.textile(withIdentity: textileIdentity))
    }

    var body: some View {
        Group {
            if let textile = textileSnapshot {
                List {
                    Section("Tekstil") {
                        LabeledContent("Navn", value: textile.name)
                        LabeledContent(
                            "Kategori",
                            value: textile.category.isEmpty ? "Ikke registrert" : textile.category
                        )
                    }

                    TextileMainImageSection(textile: textile)

                    TextileAttributesSection(
                        textile: textile,
                        model: attributesModel,
                        onAddMaterial: {
                            materialToEdit = nil
                            isEditingMaterial = true
                        },
                        onEditMaterial: { material in
                            materialToEdit = material
                            isEditingMaterial = true
                        },
                        onAddColor: {
                            colorToEdit = nil
                            isEditingColor = true
                        },
                        onEditColor: { color in
                            colorToEdit = color
                            isEditingColor = true
                        }
                    )

                    TextilePhysicalPropertiesSection(
                        textile: textile,
                        onEdit: {
                            isEditingPhysicalProperties = true
                        }
                    )

                    TextileCareSection(
                        textile: textile,
                        onEditCare: {
                            isEditingCare = true
                        }
                    )

                    TextileLocationSection(
                        textile: textile,
                        onEditLocation: {
                            isEditingLocation = true
                        }
                    )

                    if !textile.notes.isEmpty {
                        Section("Notat") {
                            Text(textile.notes)
                                .textSelection(.enabled)
                        }
                    }

                    piecesReadOnlySection

                    Section("Status") {
                        LabeledContent("Opprettet") {
                            Text(textile.createdAt, format: .dateTime.day().month().year())
                        }
                        LabeledContent("Sist endret") {
                            Text(textile.updatedAt, format: .dateTime.day().month().year().hour().minute())
                        }
                    }

                    Section("CloudKit") {
                        LabeledContent("Tekstilig-ID", value: textile.textileID)

                        if let cloudRecordName = textile.cloudRecordName {
                            LabeledContent("Record name", value: cloudRecordName)
                        }
                    }
                }
                .refreshable {
                    await pieceModel.load(for: textile.textileID)
                }
                .task(id: textile.textileID) {
                    await pieceModel.loadIfNeeded(for: textile.textileID)
                }
            } else {
                ContentUnavailableView(
                    "Tekstilet finnes ikke",
                    systemImage: "questionmark.folder"
                )
            }
        }
        .navigationTitle(textileSnapshot?.name ?? "Tekstil")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Rediger") {
                    isEditingBasics = true
                }
                .disabled(textileSnapshot == nil)
            }
        }
        .sheet(isPresented: $isEditingBasics) {
            if let textile = textileSnapshot {
                TextileEditorView(textile: textile) { candidate in
                    let saved = try await model.save(candidate)
                    textileSnapshot = saved
                    return saved
                }
            }
        }
        .sheet(isPresented: $isEditingMaterial) {
            if let textile = textileSnapshot {
                TextileMaterialEditorView(
                    material: materialToEdit,
                    textileID: textile.textileID
                ) { candidate in
                    try await attributesModel.saveMaterial(candidate)
                }
            }
        }
        .sheet(isPresented: $isEditingColor) {
            if let textile = textileSnapshot {
                TextileColorEditorView(
                    color: colorToEdit,
                    textileID: textile.textileID
                ) { candidate in
                    try await attributesModel.saveColor(candidate)
                }
            }
        }
        .sheet(isPresented: $isEditingPhysicalProperties) {
            if let textile = textileSnapshot {
                TextilePhysicalPropertiesEditorView(textile: textile) { candidate in
                    let saved = try await model.save(candidate)
                    textileSnapshot = saved
                    return saved
                }
            }
        }
        .sheet(isPresented: $isEditingCare) {
            if let textile = textileSnapshot {
                TextileCareEditorView(textile: textile) { candidate in
                    let saved = try await model.save(candidate)
                    textileSnapshot = saved
                    return saved
                }
            }
        }
        .sheet(isPresented: $isEditingLocation) {
            if let textile = textileSnapshot {
                TextileLocationEditorView(textile: textile) { candidate in
                    let saved = try await model.save(candidate)
                    textileSnapshot = saved
                    return saved
                }
            }
        }
        .sheet(isPresented: $isAddingPiece) {
            if let textile = textileSnapshot {
                PieceEditorView(
                    piece: nil,
                    textileID: textile.textileID
                ) { candidate in
                    try await pieceModel.save(candidate)
                }
            }
        }
        .sheet(item: $editingPiece) { piece in
            if let textile = textileSnapshot {
                PieceEditorView(
                    piece: piece,
                    textileID: textile.textileID
                ) { candidate in
                    try await pieceModel.save(candidate)
                }
            }
        }
        .alert(
            "Slett stoffstykke?",
            isPresented: Binding(
                get: { piecePendingDeletion != nil },
                set: { if !$0 { piecePendingDeletion = nil } }
            ),
            presenting: piecePendingDeletion
        ) { piece in
            Button("Slett", role: .destructive) {
                deletePiece(piece)
            }
            Button("Avbryt", role: .cancel) { }
        } message: { piece in
            Text("Stoffstykket på \(piece.lengthCm) × \(piece.widthCm) cm slettes permanent fra CloudKit.")
        }
        .alert(
            "Kunne ikke endre stoffstykker",
            isPresented: Binding(
                get: { pieceModel.errorMessage != nil && !pieceModel.pieces.isEmpty },
                set: { if !$0 { pieceModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(pieceModel.errorMessage ?? "Ukjent feil")
        }
    }

    private func deletePiece(_ piece: Piece) {
        Task {
            do {
                try await pieceModel.delete(piece)
                piecePendingDeletion = nil
            } catch {
                pieceModel.errorMessage = error.localizedDescription
                piecePendingDeletion = nil
            }
        }
    }

    @ViewBuilder
    private var piecesReadOnlySection: some View {
        Section {
            if pieceModel.isLoading && pieceModel.pieces.isEmpty {
                ProgressView("Henter stoffstykker …")
            } else if let errorMessage = pieceModel.errorMessage,
                      pieceModel.pieces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Kunne ikke hente stoffstykker", systemImage: "icloud.slash")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Button("Prøv igjen") {
                        if let textile = textileSnapshot {
                            Task {
                                await pieceModel.load(for: textile.textileID)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            } else if pieceModel.pieces.isEmpty {
                Text("Ingen stoffstykker registrert")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(pieceModel.pieces) { piece in
                    Button {
                        editingPiece = piece
                    } label: {
                        PieceRow(piece: piece)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Slett", role: .destructive) {
                            piecePendingDeletion = piece
                        }
                    }
                }
            }

            Button {
                isAddingPiece = true
            } label: {
                Label("Legg til stoffstykke", systemImage: "plus")
            }
        } header: {
            Text("Stoffstykker")
        } footer: {
            Text("Trykk på et stoffstykke for å redigere dimensjoner eller reservasjon.")
        }
    }
}

private struct PieceRow: View {
    let piece: Piece

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(piece.lengthCm) × \(piece.widthCm) cm")
                .font(.headline)

            if piece.isReserved {
                Text("Reservert \(piece.reservedLengthCm) cm til \(piece.project)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Tilgjengelig: \(piece.availableLengthCm) cm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Tilgjengelig: \(piece.availableLengthCm) cm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
