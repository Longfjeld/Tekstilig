import SwiftUI

struct TextileDetailView: View {
    let textileIdentity: String
    let model: TextileLibraryModel

    @State private var textileSnapshot: Textile?
    @State private var showEditor = false
    @State private var showNewPiece = false
    @State private var editingPiece: Piece?
    @State private var piecePendingDeletion: Piece?
    @State private var pieceModel = PieceInventoryModel()
    @State private var attributesModel = TextileAttributesModel()
    @State private var attributeEditorRoute: AttributeEditorRoute?
    @State private var showLocationEditor = false
    @State private var showCareEditor = false
    @State private var showPhysicalPropertiesEditor = false
    @State private var imageModel = TextileImageModel()

    #if os(iOS)
    @State private var showImageCamera = false
    #endif

    init(textileIdentity: String, model: TextileLibraryModel) {
        self.textileIdentity = textileIdentity
        self.model = model
        _textileSnapshot = State(initialValue: model.textile(withIdentity: textileIdentity))
    }

    var body: some View {
        Group {
            if let textile = textileSnapshot {
                textileScreen(for: textile)
            } else {
                missingTextileView
            }
        }
    }

    private var missingTextileView: some View {
        ContentUnavailableView(
            "Tekstilet finnes ikke",
            systemImage: "questionmark.folder",
            description: Text("Oppdater tekstilbiblioteket og prøv igjen.")
        )
    }

    private func textileScreen(for textile: Textile) -> some View {
        let base = textileBaseScreen(for: textile)
        let withEditors = editorPresentations(base, textile: textile)
        let withPieces = piecePresentations(withEditors, textile: textile)
        let withCamera = cameraPresentation(withPieces, textile: textile)
        return alertPresentations(withCamera)
    }

    private func textileBaseScreen(for textile: Textile) -> some View {
        textileList(for: textile)
            .navigationTitle(textile.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Rediger") {
                        showEditor = true
                    }
                }
            }
            .refreshable {
                await pieceModel.load(for: textile.textileID)
            }
            .task(id: textile.textileID) {
                await pieceModel.loadIfNeeded(for: textile.textileID)
            }
    }

    private func editorPresentations<Content: View>(
        _ content: Content,
        textile: Textile
    ) -> some View {
        content
            .sheet(isPresented: $showEditor) {
                TextileEditorView(textile: textile) { candidate in
                    try await saveTextile(candidate)
                }
            }
            .sheet(item: $attributeEditorRoute) { route in
                attributeEditor(for: route, textile: textile)
            }
            .sheet(isPresented: $showCareEditor) {
                TextileCareEditorView(textile: textile) { candidate in
                    try await saveTextile(candidate)
                }
            }
            .sheet(isPresented: $showPhysicalPropertiesEditor) {
                TextilePhysicalPropertiesEditorView(textile: textile) { candidate in
                    try await saveTextile(candidate)
                }
            }
            .sheet(isPresented: $showLocationEditor) {
                TextileLocationEditorView(textile: textile) { candidate in
                    try await saveTextile(candidate)
                }
            }
    }

    private func piecePresentations<Content: View>(
        _ content: Content,
        textile: Textile
    ) -> some View {
        content
            .sheet(isPresented: $showNewPiece) {
                PieceEditorView(piece: nil, textileID: textile.textileID) { candidate in
                    try await pieceModel.save(candidate)
                }
            }
            .sheet(item: $editingPiece) { piece in
                PieceEditorView(piece: piece, textileID: textile.textileID) { candidate in
                    try await pieceModel.save(candidate)
                }
            }
    }

    @ViewBuilder
    private func cameraPresentation<Content: View>(
        _ content: Content,
        textile: Textile
    ) -> some View {
        #if os(iOS)
        content
            .fullScreenCover(isPresented: $showImageCamera) {
                TextileCameraPicker { data in
                    saveCameraImage(data, textileID: textile.textileID)
                }
                .ignoresSafeArea()
            }
        #else
        content
        #endif
    }

    private func alertPresentations<Content: View>(_ content: Content) -> some View {
        content
            .alert(
                "Slett stoffstykke?",
                isPresented: Binding(
                    get: { piecePendingDeletion != nil },
                    set: { if !$0 { piecePendingDeletion = nil } }
                ),
                presenting: piecePendingDeletion
            ) { piece in
                Button("Slett", role: .destructive) {
                    delete(piece)
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

    private func textileList(for textile: Textile) -> some View {
        List {
            textileSummarySection(for: textile)

            TextileMainImageSection(
                textile: textile,
                model: imageModel,
                onTakePhoto: {
                    #if os(iOS)
                    showImageCamera = true
                    #endif
                }
            )

            TextileAttributesSection(
                textile: textile,
                model: attributesModel,
                onAddMaterial: {
                    attributeEditorRoute = .newMaterial
                },
                onEditMaterial: { material in
                    attributeEditorRoute = .editMaterial(material)
                },
                onAddColor: {
                    attributeEditorRoute = .newColor
                },
                onEditColor: { color in
                    attributeEditorRoute = .editColor(color)
                }
            )

            TextileCareSection(
                textile: textile,
                onEditCare: {
                    showCareEditor = true
                }
            )

            TextilePhysicalPropertiesSection(
                textile: textile,
                onEdit: {
                    showPhysicalPropertiesEditor = true
                }
            )

            TextileLocationSection(
                textile: textile,
                onEditLocation: {
                    showLocationEditor = true
                }
            )

            piecesSection(for: textile)
            cloudKitSection(for: textile)
            statusSection(for: textile)
        }
    }

    private func textileSummarySection(for textile: Textile) -> some View {
        Section("Tekstil") {
            LabeledContent("Navn", value: textile.name)
            LabeledContent(
                "Kategori",
                value: textile.category.isEmpty ? "Ikke registrert" : textile.category
            )
        }
    }

    private func piecesSection(for textile: Textile) -> some View {
        Section {
            pieceRows(for: textile)

            Button {
                showNewPiece = true
            } label: {
                Label("Legg til stoffstykke", systemImage: "plus")
            }
        } header: {
            Text("Stoffstykker")
        } footer: {
            Text("Trykk på et stoffstykke for å redigere dimensjoner eller reservasjon.")
        }
    }

    @ViewBuilder
    private func pieceRows(for textile: Textile) -> some View {
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
                    Task {
                        await pieceModel.load(for: textile.textileID)
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
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Slett", role: .destructive) {
                        piecePendingDeletion = piece
                    }
                }
            }
        }
    }

    private func cloudKitSection(for textile: Textile) -> some View {
        Section("CloudKit") {
            LabeledContent("Tekstilig-ID", value: textile.textileID)

            if let cloudRecordName = textile.cloudRecordName {
                LabeledContent("Record name", value: cloudRecordName)
            }
        }
    }

    private func statusSection(for textile: Textile) -> some View {
        Section("Status") {
            LabeledContent("Opprettet") {
                Text(textile.createdAt, format: .dateTime.day().month().year())
            }
            LabeledContent("Sist endret") {
                Text(textile.updatedAt, format: .dateTime.day().month().year().hour().minute())
            }
        }
    }

    @ViewBuilder
    private func attributeEditor(for route: AttributeEditorRoute, textile: Textile) -> some View {
        switch route {
        case .newMaterial:
            TextileMaterialEditorView(material: nil, textileID: textile.textileID) { candidate in
                try await attributesModel.saveMaterial(candidate)
            }
        case .editMaterial(let material):
            TextileMaterialEditorView(material: material, textileID: textile.textileID) { candidate in
                try await attributesModel.saveMaterial(candidate)
            }
        case .newColor:
            TextileColorEditorView(color: nil, textileID: textile.textileID) { candidate in
                try await attributesModel.saveColor(candidate)
            }
        case .editColor(let color):
            TextileColorEditorView(color: color, textileID: textile.textileID) { candidate in
                try await attributesModel.saveColor(candidate)
            }
        }
    }

    private func saveTextile(_ candidate: Textile) async throws -> Textile {
        let saved = try await model.save(candidate)
        textileSnapshot = saved
        return saved
    }

    #if os(iOS)
    private func saveCameraImage(_ data: Data, textileID: String) {
        Task {
            do {
                let optimized = try QuickRegistrationImageOptimizer.optimize(data)
                let fileName = "tekstilig-main-\(UUID().uuidString.lowercased()).jpg"

                await imageModel.savePrimaryImage(
                    textileID: textileID,
                    data: optimized,
                    fileName: fileName,
                    contentType: "image/jpeg"
                )
            } catch {
                imageModel.errorMessage = error.localizedDescription
            }
        }
    }
    #endif

    private func delete(_ piece: Piece) {
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
}

private enum AttributeEditorRoute: Identifiable {
    case newMaterial
    case editMaterial(TextileMaterial)
    case newColor
    case editColor(TextileColor)

    var id: String {
        switch self {
        case .newMaterial:
            return "new-material"
        case .editMaterial(let material):
            return "edit-material-\(material.id)"
        case .newColor:
            return "new-color"
        case .editColor(let color):
            return "edit-color-\(color.id)"
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
