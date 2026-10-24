import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct DeveloperDiagnosticsView: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var diagnostic = CloudKitAssetDiagnosticModel()
    @State private var pieceDiagnostic = CloudKitPieceDiagnosticModel()
    @State private var backupDiagnostic = BackupDiagnosticModel()
    @State private var showBackupExporter = false
    @State private var showBackupImporter = false
    @State private var isReadingBackup = false
    @State private var validatedZIPData: Data?
    @State private var negativeZIPTestResult: String?
    @State private var negativeJSONTestResult: String?
    @State private var importResult: TekstiligBackupReader.Result?
    @State private var importError: String?
    @State private var importPlan: String?
    @State private var isPlanningImport = false
    @State private var conflictReport: String?
    @State private var isCheckingConflicts = false
    @State private var stabilityReport: String?
    @State private var isCheckingStability = false
    @State private var identityAudit: String?
    @State private var isAuditingIdentities = false
    @State private var backupExportMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Forutsetning") {
                    Label("Steg 6: native CloudKit er validert", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)

                    LabeledContent("Container", value: CloudKitAssetDiagnosticModel.containerIdentifier)
                    LabeledContent("Database", value: "Private / Development")
                    LabeledContent("Textile", value: CloudKitAssetDiagnosticModel.textileRecordName)
                }

                Section("1. Velg testbilde") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Velg bilde fra Bilder", systemImage: "photo.on.rectangle")
                    }

                    if let data = diagnostic.selectedImageData {
                        DiagnosticImage(data: data)

                        LabeledContent("Fil", value: diagnostic.selectedFileName)
                        LabeledContent("Type", value: diagnostic.selectedContentType)
                        LabeledContent("Størrelse", value: byteCount(diagnostic.selectedByteCount))
                    } else {
                        Text("Velg ett lite bilde. For denne tekniske testen trenger vi ikke kamera i appen ennå.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button {
                        Task {
                            await diagnostic.run()
                        }
                    } label: {
                        if diagnostic.isRunning {
                            HStack {
                                ProgressView()
                                Text("Tester CKAsset …")
                            }
                        } else {
                            Label("Lagre og les CKAsset", systemImage: "icloud.and.arrow.up")
                        }
                    }
                    .disabled(diagnostic.isRunning || !diagnostic.hasSelectedImage)
                } header: {
                    Text("2. Kjør CKAsset-test")
                } footer: {
                    Text("Testen gjenbruker recorden swiftui-poc-textile-image-v1. Nye testkjøringer oppretter derfor ikke stadig nye TextileImage-records.")
                }

                if !diagnostic.logEntries.isEmpty {
                    Section("Resultat") {
                        ForEach(diagnostic.logEntries) { entry in
                            Label {
                                Text(entry.message)
                                    .font(.callout)
                            } icon: {
                                Image(systemName: entry.isError ? "xmark.circle.fill" : "checkmark.circle")
                                    .foregroundStyle(entry.isError ? .red : .secondary)
                            }
                        }
                    }
                }

                if let data = diagnostic.fetchedImageData {
                    Section("Bilde lest tilbake fra CloudKit") {
                        DiagnosticImage(data: data)

                        LabeledContent("Record name", value: diagnostic.imageRecordName)
                        LabeledContent("Nedlastet", value: byteCount(diagnostic.fetchedByteCount))
                    }
                }

                if diagnostic.completedSuccessfully {
                    Section {
                        Label("Steg 7 er fullført", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } footer: {
                        Text("Steg 8 er validert fra en separat iOS-simulator med samme iCloud-konto.")
                    }
                }

                Section {
                    Button {
                        Task {
                            await pieceDiagnostic.run()
                        }
                    } label: {
                        if pieceDiagnostic.isRunning {
                            HStack {
                                ProgressView()
                                Text("Tester Piece …")
                            }
                        } else {
                            Label("Kjør Piece-test", systemImage: "scissors")
                        }
                    }
                    .disabled(pieceDiagnostic.isRunning)
                } header: {
                    Text("Steg 9: valider Piece")
                } footer: {
                    Text("Piece-testen bruker den eksisterende test-Textile og gjenbruker recorden swiftui-poc-piece-v1.")
                }

                if !pieceDiagnostic.logEntries.isEmpty {
                    Section("Piece-resultat") {
                        ForEach(pieceDiagnostic.logEntries) { entry in
                            Label {
                                Text(entry.message)
                                    .font(.callout)
                            } icon: {
                                Image(systemName: entry.isError ? "xmark.circle.fill" : "checkmark.circle")
                                    .foregroundStyle(entry.isError ? .red : .secondary)
                            }
                        }
                    }
                }

                if pieceDiagnostic.completedSuccessfully {
                    Section("Piece lest tilbake fra CloudKit") {
                        LabeledContent("Record name", value: pieceDiagnostic.recordName)
                        LabeledContent("pieceId", value: CloudKitPieceDiagnosticModel.pieceID)
                        LabeledContent("textileId", value: pieceDiagnostic.textileID)
                        LabeledContent("Lengde", value: "\(pieceDiagnostic.lengthCm) cm")
                        LabeledContent("Bredde", value: "\(pieceDiagnostic.widthCm) cm")
                        LabeledContent("Reservert", value: "\(pieceDiagnostic.reservedLengthCm) cm")
                        LabeledContent("Prosjekt", value: pieceDiagnostic.project)
                    }

                    Section {
                        Label("Steg 9 er fullført", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } footer: {
                        Text("Native PoC er fullført: Textile, TextileImage/CKAsset, separat klientinstans og Piece er validert.")
                    }
                }

                Section {
                    Button {
                        Task {
                            await backupDiagnostic.run()
                        }
                    } label: {
                        if backupDiagnostic.isRunning {
                            BackupActivityLabel("Bygger og kontrollerer backup …")
                        } else {
                            Label("Test backupmodell", systemImage: "archivebox")
                        }
                    }
                    .disabled(backupDiagnostic.isRunning || isReadingBackup)
                } header: {
                    Text("Roadmap 6: backupmodell")
                } footer: {
                    Text("Bygger backup i minnet, kontrollerer JSON og skriver deretter backup.json og bilder til en midlertidig mappe. Kontrollerer filene og sletter mappen etter testen. Ingen CloudKit-data endres.")
                }

                if backupDiagnostic.zipSuccessfully, backupDiagnostic.exportDocument != nil {
                    Section("Eksporter backup") {
                        Label("ZIP opprettet og innhold kontrollert", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        LabeledContent("ZIP-størrelse", value: byteCount(backupDiagnostic.zipByteCount))
                        Button("Lagre backup som ZIP …") { showBackupExporter = true }
                            .disabled(isReadingBackup || backupDiagnostic.isRunning)
                        if let backupExportMessage { Text(backupExportMessage) }
                    }
                }

                Section("Roadmap 7: les backup (kun kontroll)") {
                    Button("Velg ZIP-backup …") { showBackupImporter = true }
                        .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    if isReadingBackup {
                        BackupActivityLabel("Leser og kontrollerer backup …")
                    }
                    if importResult != nil {
                        Label("Backup lest og validert – ingen data importert", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Forhåndsvisningen er skrivebeskyttet. Ingen tekstiler, bilder eller stoffstykker er gjenopprettet.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    if importResult != nil {
                        Button("Beregn importplan (kun kontroll)") {
                            Task { await calculateImportPlan() }
                        }
                        .disabled(isReadingBackup || isPlanningImport || backupDiagnostic.isRunning)
                        if isPlanningImport {
                            BackupActivityLabel("Sammenligner med iCloud-biblioteket …")
                        }
                        if let importPlan {
                            Text(importPlan).font(.callout)
                        }
                        Button("Kontroller importkonflikter (kun kontroll)") {
                            Task { await checkImportConflicts() }
                        }
                        .disabled(isReadingBackup || isPlanningImport || isCheckingConflicts || isCheckingStability || isAuditingIdentities || backupDiagnostic.isRunning)
                        if isCheckingConflicts {
                            BackupActivityLabel("Kontrollerer importkonflikter …")
                        }
                        if let conflictReport {
                            Text(conflictReport).font(.callout)
                        }
                        Button("Kontroller endringer mellom to CloudKit-lesinger (kun kontroll)") {
                            Task { await checkCloudKitStability() }
                        }
                        .disabled(isReadingBackup || isPlanningImport || isCheckingConflicts || isCheckingStability || isAuditingIdentities || backupDiagnostic.isRunning)
                        if isCheckingStability {
                            BackupActivityLabel("Leser CloudKit-identiteter to ganger …")
                        }
                        if let stabilityReport {
                            Text(stabilityReport).font(.callout)
                        }
                        Button("Kartlegg CloudKit-identiteter (kun kontroll)") {
                            Task { await auditCloudKitIdentities() }
                        }
                        .disabled(isReadingBackup || isPlanningImport || isAuditingIdentities || backupDiagnostic.isRunning)
                        if isAuditingIdentities {
                            BackupActivityLabel("Kartlegger CloudKit-poster …")
                        }
                        if let identityAudit {
                            Text(identityAudit).font(.callout)
                        }
                    }
                    if let importError {
                        Text(importError).foregroundStyle(.orange)
                    }
                    if validatedZIPData != nil {
                        Button("Test avvisning av ugyldige ZIP-filer") {
                            runNegativeZIPTests()
                        }
                        .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    }
                    if validatedZIPData != nil {
                        Button("Test avvisning av ugyldig backupinnhold") {
                            runNegativeJSONTests()
                        }
                        .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    }
                    if let negativeJSONTestResult {
                        Text(negativeJSONTestResult)
                            .foregroundStyle(negativeJSONTestResult.hasPrefix("OK") ? .green : .orange)
                    }
                    if let negativeZIPTestResult {
                        Text(negativeZIPTestResult)
                            .foregroundStyle(negativeZIPTestResult.hasPrefix("OK") ? .green : .orange)
                    }
                }

                if let importResult {
                    Section("Forhåndsvisning av backup") {
                        LabeledContent("Eksportert", value: importResult.document.exportedAt.formatted(date: .abbreviated, time: .shortened))
                        LabeledContent("Backupformat", value: importResult.document.format)
                        LabeledContent("Formatversjon", value: String(importResult.document.formatVersion))
                        LabeledContent("Tekstiler", value: String(importResult.document.textiles.count))
                        LabeledContent("Stoffstykker", value: String(importResult.pieceCount))
                        LabeledContent("Bilder", value: String(importResult.imageCount))
                        LabeledContent("Materialregistreringer", value: String(importResult.document.textiles.reduce(0) { $0 + $1.materials.count }))
                        LabeledContent("Fargeregistreringer", value: String(importResult.document.textiles.reduce(0) { $0 + $1.colors.count }))
                    }
                }

                if backupDiagnostic.completedSuccessfully {
                    Section("Backupmodell validert") {
                        Label("JSON round-trip OK", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        if backupDiagnostic.stagedSuccessfully {
                            Label("backup.json og bilder skrevet og kontrollert", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                        LabeledContent("Tekstiler", value: "\(backupDiagnostic.textileCount)")
                        LabeledContent("Materialer", value: "\(backupDiagnostic.materialCount)")
                        LabeledContent("Farger", value: "\(backupDiagnostic.colorCount)")
                        LabeledContent("Stoffstykker", value: "\(backupDiagnostic.pieceCount)")
                        LabeledContent("Bilder", value: "\(backupDiagnostic.imageCount)")
                        LabeledContent("JSON-størrelse", value: byteCount(backupDiagnostic.jsonByteCount))
                        LabeledContent("Bildedata", value: byteCount(backupDiagnostic.imageByteCount))
                    }
                } else if let errorMessage = backupDiagnostic.errorMessage {
                    Section("Backupmodell – feil") {
                        Label {
                            Text(errorMessage)
                                .font(.callout)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Diagnostikk")
            .fileExporter(isPresented: $showBackupExporter,
                          document: backupDiagnostic.exportDocument,
                          contentType: .zip,
                          defaultFilename: "Tekstilig-backup") { result in
                switch result {
                case .success: backupExportMessage = "Backup lagret."
                case .failure(let error): backupExportMessage = "Eksport feilet: \(error.localizedDescription)"
                }
            }
            .fileImporter(isPresented: $showBackupImporter, allowedContentTypes: [.zip]) { result in
                guard !isReadingBackup else { return }
                importResult = nil
                importPlan = nil
                conflictReport = nil
                stabilityReport = nil
                identityAudit = nil
                validatedZIPData = nil
                negativeZIPTestResult = nil
                negativeJSONTestResult = nil
                importError = nil
                switch result {
                case .failure(let error):
                    // Cancel is not a failed import; do not start an activity indicator.
                    if (error as NSError).code != NSUserCancelledError {
                        importError = "Kunne ikke velge backup: \(error.localizedDescription)"
                    }
                case .success(let url):
                    isReadingBackup = true
                    Task {
                        do {
                            // Copy bytes off the UI actor while the security scope is active.
                            let data = try await Task.detached(priority: .userInitiated) {
                                let accessed = url.startAccessingSecurityScopedResource()
                                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                                return try Data(contentsOf: url)
                            }.value
                            // Validation remains in the existing canonical reader.
                            importResult = try TekstiligBackupReader().read(data)
                            validatedZIPData = data
                        } catch {
                            importError = "Kunne ikke lese backup: \(error.localizedDescription)"
                        }
                        isReadingBackup = false
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    await loadSelectedPhoto(newItem)
                }
            }
        }
    }

    // Read-only comparison against the current private CloudKit library. No writes.
    @MainActor
    private func calculateImportPlan() async {
        guard let result = importResult, !isPlanningImport else { return }
        isPlanningImport = true
        importPlan = nil
        defer { isPlanningImport = false }
        do {
            let current = try await CloudKitTextileRepository().fetchTextiles()
            let existingIDs = Set(current.map(\.textileID))
            let incomingIDs = Set(result.document.textiles.map(\.textileID))
            let newTextiles = result.document.textiles.filter { !existingIDs.contains($0.textileID) }
            let overlappingTextiles = result.document.textiles.filter { existingIDs.contains($0.textileID) }
            // A logical textileID is not the CloudKit recordName. Detect duplicate
            // logical IDs in the live library before any future restore design.
            let liveIDCounts = Dictionary(grouping: current, by: \.textileID)
            let ambiguousIDs = liveIDCounts.filter { $0.value.count > 1 }.count

            // Count children from the validated backup, not from CloudKit. These are
            // prospective operations only; no child records or assets are fetched/written.
            func childCounts(_ textiles: [TekstiligBackupTextile]) -> String {
                let pieces = textiles.reduce(0) { $0 + $1.pieces.count }
                let images = textiles.reduce(0) { $0 + $1.images.count }
                let materials = textiles.reduce(0) { $0 + $1.materials.count }
                let colors = textiles.reduce(0) { $0 + $1.colors.count }
                return "\(textiles.count) tekstiler, \(pieces) stoffstykker, \(images) bilder, \(materials) materialer, \(colors) farger"
            }

            importPlan = "Importplan (ingen endringer utført):\n" +
                "Eksisterende tekstiler i iCloud: \(current.count)\n" +
                "Tekstiler i backup: \(incomingIDs.count)\n\n" +
                "Importer bare nye:\n" +
                "  Ville importert: \(childCounts(newTextiles))\n" +
                "  Ville hoppet over: \(childCounts(overlappingTextiles)) (samme tekstil-ID)\n\n" +
                "Erstatt hele biblioteket:\n" +
                "  Backupinnhold: \(childCounts(result.document.textiles))\n" +
                "  Eksisterende tekstiler som må håndteres: \(current.count)\n\n" +
                "Sikkerhetsvurdering før eventuell import:\n" +
                "  Dupliserte tekstil-ID-er i iCloud: \(ambiguousIDs)\n" +
                "  Skriving til CloudKit: SPERRET (ikke implementert)\n" +
                "  Identitet: tekstil-ID er ikke det samme som CloudKit recordName.\n" +
                "  Import krever kontroll av underposter og bilder, ny kontroll rett før skriving, " +
                "og gjenopprettingsstrategi ved delvis feil.\n\n" +
                "Viktig: Eksisterende stoffstykker, bilder og andre underposter i iCloud er ikke lest eller sammenlignet. " +
                "Dette er kun en ID-basert forhåndsberegning, ikke en trygg utførelsesplan. " +
                "Ingen data er importert eller slettet."
        } catch {
            importPlan = "Kunne ikke beregne importplan: \(error.localizedDescription). Ingen data er endret."
        }
    }

    // Preflight rules for "Importer bare nye". This is a read-only decision,
    // not an authorization to write: the live library can change after this read.
    @MainActor
    private func checkImportConflicts() async {
        guard let result = importResult, !isCheckingConflicts else { return }
        isCheckingConflicts = true
        conflictReport = nil
        defer { isCheckingConflicts = false }
        do {
            let existing = try await CloudKitTextileRepository().fetchTextiles()
            let incoming = result.document.textiles
            let existingIDs = Set(existing.map(\.textileID))
            let newTextiles = incoming.filter { !existingIDs.contains($0.textileID) }
            let skipped = incoming.count - newTextiles.count

            func duplicates(_ ids: [String]) -> Int {
                Dictionary(grouping: ids, by: { $0 }).values.filter { $0.count > 1 }.count
            }
            let liveDuplicates = duplicates(existing.map(\.textileID))
            let backupDuplicates = duplicates(incoming.map(\.textileID))
            let emptyTextileIDs = incoming.filter { $0.textileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
            let allPieceIDs = incoming.flatMap { $0.pieces.map(\.pieceID) }
            let allImageIDs = incoming.flatMap { $0.images.map(\.imageID) }
            let allMaterialIDs = incoming.flatMap { $0.materials.map(\.materialID) }
            let allColorIDs = incoming.flatMap { $0.colors.map(\.colorID) }
            let childDuplicateCounts = [duplicates(allPieceIDs), duplicates(allImageIDs), duplicates(allMaterialIDs), duplicates(allColorIDs)]
            let missingChildIDs = [allPieceIDs, allImageIDs, allMaterialIDs, allColorIDs]
                .reduce(0) { count, ids in count + ids.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count }
            // Compare only children that would actually be imported. Children of
            // skipped textiles must not cause false-positive live collisions.
            let livePieces = try await CloudKitPieceRepository().fetchAllPieces().map(\.pieceID)
            let liveMaterials = try await CloudKitTextileMaterialRepository().fetchAllMaterials().map(\.materialID)
            let liveColors = try await CloudKitTextileColorRepository().fetchAllColors().map(\.colorID)
            let liveImages = try await CloudKitTextileImageRepository().fetchAllImageIDsForConflictCheck()
            let liveGroups = [livePieces, liveImages, liveMaterials, liveColors]
            let incomingNewGroups: [[String]] = [
                newTextiles.flatMap { $0.pieces.map(\.pieceID) },
                newTextiles.flatMap { $0.images.map(\.imageID) },
                newTextiles.flatMap { $0.materials.map(\.materialID) },
                newTextiles.flatMap { $0.colors.map(\.colorID) }
            ]
            let liveChildDuplicates = liveGroups.map { duplicates($0) }
            let liveMissingChildIDs = liveGroups.map { $0.filter { $0.isEmpty }.count }
            let childCollisions = zip(incomingNewGroups, liveGroups).map { incoming, live in
                incoming.filter { Set(live).contains($0) }.count
            }
            let blocked = liveDuplicates > 0 || backupDuplicates > 0 || emptyTextileIDs > 0 ||
                childDuplicateCounts.contains(where: { $0 > 0 }) || missingChildIDs > 0 ||
                liveChildDuplicates.contains(where: { $0 > 0 }) ||
                liveMissingChildIDs.contains(where: { $0 > 0 }) ||
                childCollisions.contains(where: { $0 > 0 })
            let status = blocked ? "AVVIST – identitetskonflikt" : "FORELØPIG OK – bare skrivebeskyttet vurdering"
            conflictReport = "Konfliktregler – Importer bare nye (kun kontroll):\n" +
                "Status: \(status)\n" +
                "Nye tekstiler: \(newTextiles.count), hoppes over: \(skipped)\n" +
                "Dupliserte tekstil-ID-er i iCloud: \(liveDuplicates)\n" +
                "Dupliserte tekstil-ID-er i backup: \(backupDuplicates)\n" +
                "Tomme tekstil-ID-er i backup: \(emptyTextileIDs)\n" +
                "Dupliserte underpost-ID-er i backup (stoffstykke/bilde/materiale/farge): \(childDuplicateCounts.map(String.init).joined(separator: "/"))\n" +
                "Tomme underpost-ID-er i backup: \(missingChildIDs)\n" +
                "Dupliserte underpost-ID-er i iCloud (stoffstykke/bilde/materiale/farge): \(liveChildDuplicates.map(String.init).joined(separator: "/"))\n" +
                "Tomme underpost-ID-er i iCloud (stoffstykke/bilde/materiale/farge): \(liveMissingChildIDs.map(String.init).joined(separator: "/"))\n" +
                "Kollisjoner: NYE backup-underposter mot iCloud (stoffstykke/bilde/materiale/farge): \(childCollisions.map(String.init).joined(separator: "/"))\n" +
                "Overlappende tekstiler hoppes over med ALLE underposter.\n" +
                "Skriving til CloudKit: SPERRET.\n" +
                "Alle eksisterende underpost-ID-er, også bildeposter, er sammenlignet uten å laste ned bildedata.\n" +
                "En grønn vurdering er IKKE klarsignal til import: samtidige endringer, " +
                "record-identitet og delvise feil må håndteres før skriving.\n" +
                "Ingen data er endret."
        } catch {
            conflictReport = "Konfliktkontroll AVVIST: \(error.localizedDescription). Ingen data er endret."
        }
    }

    // Diagnostic only: two consecutive enumerations are NOT an atomic snapshot.
    // This detects changes to logical IDs, parent links, record names and textile
    // updatedAt between passes. It cannot rule out concurrent writes or ABA changes.
    @MainActor
    private func checkCloudKitStability() async {
        guard importResult != nil, !isCheckingStability else { return }
        isCheckingStability = true
        stabilityReport = nil
        defer { isCheckingStability = false }
        do {
            func snapshot() async throws -> [[String]] {
                let textiles = try await CloudKitTextileRepository().fetchTextiles()
                let pieces = try await CloudKitPieceRepository().fetchAllPieces()
                let materials = try await CloudKitTextileMaterialRepository().fetchAllMaterials()
                let colors = try await CloudKitTextileColorRepository().fetchAllColors()
                let images = try await CloudKitTextileImageRepository().fetchAllImageIDsForConflictCheck()
                return [
                    textiles.map { "\($0.textileID)|\($0.cloudRecordName ?? "")|\($0.updatedAt.timeIntervalSince1970)" }.sorted(),
                    pieces.map { "\($0.pieceID)|\($0.textileID)|\($0.cloudRecordName ?? "")" }.sorted(),
                    images.sorted(),
                    materials.map { "\($0.materialID)|\($0.textileID)|\($0.cloudRecordName ?? "")" }.sorted(),
                    colors.map { "\($0.colorID)|\($0.textileID)|\($0.cloudRecordName ?? "")" }.sorted()
                ]
            }
            let first = try await snapshot()
            let second = try await snapshot()
            let names = ["Tekstiler", "Stoffstykker", "Bilder (kun ID)", "Materialer", "Farger"]
            let changes = zip(first, second).enumerated().compactMap { index, pair -> String? in
                pair.0 == pair.1 ? nil : names[index]
            }
            let status = changes.isEmpty ? "INGEN ENDRINGER OBSERVERT" : "ENDRINGER OPPDAGET – AVVIST"
            stabilityReport = "CloudKit-stabilitet (to lesinger, kun kontroll):\n" +
                "Status: \(status)\n" +
                "Antall første/andre lesing (tekstil/stykke/bilde/materiale/farge): " +
                "\(first.map(\.count).map(String.init).joined(separator: "/")) / " +
                "\(second.map(\.count).map(String.init).joined(separator: "/"))\n" +
                "Endrede grupper: \(changes.isEmpty ? "Ingen" : changes.joined(separator: ", "))\n" +
                "Dette er IKKE en transaksjon eller en skriveautorisasjon. Bildeinnhold og bilde-recordName er ikke kontrollert. " +
                "Endringer kan skje etter kontrollen eller mellom enkeltoppslag; en endring som reverseres kan overses.\n" +
                "For sikker import kreves kontroll rett før hver skriveoperasjon, idempotente record-identiteter " +
                "og eksplisitt plan for delvise feil og opprydding.\n" +
                "Skriving til CloudKit: SPERRET. Ingen data er endret."
        } catch {
            stabilityReport = "CloudKit-stabilitet AVVIST: Lesing feilet: \(error.localizedDescription). " +
                "Skriving til CloudKit: SPERRET. Ingen data er endret."
        }
    }

    // Read-only audit. Every returned record is mapped by logical ID and CKRecord name.
    // The image audit enumerates every non-diagnostic TextileImage record without loading assets.
    @MainActor
    private func auditCloudKitIdentities() async {
        guard importResult != nil, !isAuditingIdentities else { return }
        isAuditingIdentities = true
        identityAudit = nil
        defer { isAuditingIdentities = false }
        do {
            let textiles = try await CloudKitTextileRepository().fetchTextiles()
            let pieces = try await CloudKitPieceRepository().fetchAllPieces()
            let materials = try await CloudKitTextileMaterialRepository().fetchAllMaterials()
            let colors = try await CloudKitTextileColorRepository().fetchAllColors()
            let parentIDs = Set(textiles.map(\.textileID))
            let imageAudit = try await CloudKitTextileImageRepository().auditAllImageRecords(knownTextileIDs: parentIDs)

            func duplicateCount(_ ids: [String]) -> Int {
                Dictionary(grouping: ids, by: { $0 }).values.filter { $0.count > 1 }.count
            }
            func missingParents(_ ids: [String]) -> Int {
                ids.filter { !parentIDs.contains($0) }.count
            }
            func missingRecordNames(_ names: [String?]) -> Int {
                names.filter { $0 == nil || $0!.isEmpty }.count
            }
            identityAudit = "CloudKit-identitetskart (kun lesing):\n" +
                "Tekstiler: \(textiles.count), dupliserte ID-er: \(duplicateCount(textiles.map(\.textileID))), uten recordName: \(missingRecordNames(textiles.map(\.cloudRecordName)))\n" +
                "Stoffstykker: \(pieces.count), dupliserte ID-er: \(duplicateCount(pieces.map(\.pieceID))), uten forelder: \(missingParents(pieces.map(\.textileID))), uten recordName: \(missingRecordNames(pieces.map(\.cloudRecordName)))\n" +
                "Materialer: \(materials.count), dupliserte ID-er: \(duplicateCount(materials.map(\.materialID))), uten forelder: \(missingParents(materials.map(\.textileID))), uten recordName: \(missingRecordNames(materials.map(\.cloudRecordName)))\n" +
                "Farger: \(colors.count), dupliserte ID-er: \(duplicateCount(colors.map(\.colorID))), uten forelder: \(missingParents(colors.map(\.textileID))), uten recordName: \(missingRecordNames(colors.map(\.cloudRecordName)))\n" +
                imageAudit + "\n\n" +
                "Bildekartleggingen leser metadata, ikke CKAsset-bildedata.\n" +
                "Skriving til CloudKit: SPERRET. Ingen data endret."
        } catch {
            identityAudit = "Kartlegging avbrutt: \(error.localizedDescription). Ingen data endret."
        }
    }

    // Negative tests modify an in-memory copy only. The original backup is never written.
    @MainActor
    private func runNegativeZIPTests() {
        guard let original = validatedZIPData else { return }
        var scenarios: [(String, Data)] = []
        scenarios.append(("Avkortet ZIP", Data(original.dropLast(min(10, original.count)))))

        var damagedSignature = original
        if !damagedSignature.isEmpty {
            damagedSignature[damagedSignature.startIndex] ^= 0x01
            scenarios.append(("Ugyldig ZIP-header", damagedSignature))
        }

        // The exporter writes backup.json first, with a 30-byte local ZIP header.
        // Mutating one payload byte must be detected by the existing CRC32 check.
        let bytes = [UInt8](original)
        if bytes.count >= 30,
           bytes[0...3].elementsEqual([0x50, 0x4b, 0x03, 0x04]) {
            let nameLength = Int(bytes[26]) | (Int(bytes[27]) << 8)
            let extraLength = Int(bytes[28]) | (Int(bytes[29]) << 8)
            let payloadOffset = 30 + nameLength + extraLength
            if payloadOffset < bytes.count {
                var damagedPayload = original
                damagedPayload[payloadOffset] ^= 0x01
                scenarios.append(("Endret filinnhold (CRC32)", damagedPayload))
            }
        }

        guard scenarios.count == 3 else {
            negativeZIPTestResult = "FEIL: Kunne ikke konstruere alle tre testtilfellene."
            return
        }
        var failures: [String] = []
        for (name, data) in scenarios {
            do {
                _ = try TekstiligBackupReader().read(data)
                failures.append(name + " ble feilaktig godkjent")
            } catch {
                // Expected: the reader must reject invalid data.
            }
        }
        negativeZIPTestResult = failures.isEmpty
            ? "OK: 3/3 ugyldige ZIP-varianter ble avvist. Ingen data importert."
            : "FEIL: " + failures.joined(separator: "; ")
    }

    // Read-only semantic tests use the exact validator called by ZIP import.
    @MainActor
    private func runNegativeJSONTests() {
        guard let original = importResult?.document else { return }
        let reader = TekstiligBackupReader()
        let paths = Set(original.textiles.flatMap(\.images).map(\.backupPath))
        var cases: [(String, TekstiligBackupDocument, Set<String>)] = []

        var wrongVersion = original
        wrongVersion.formatVersion = TekstiligBackupDocument.currentFormatVersion + 1
        cases.append(("Ukjent formatversjon", wrongVersion, paths))

        var missingImage = original
        // A missing referenced file is invalid even when the source backup has no images.
        if let first = missingImage.textiles.indices.first {
            let missingPath = "images/does-not-exist.jpeg"
            if !missingImage.textiles[first].images.isEmpty {
                missingImage.textiles[first].images[0].backupPath = missingPath
            } else {
                // With no image references, an unexpected image file is equally invalid.
                cases.append(("Uventet bildefil", missingImage, paths.union([missingPath])))
            }
            if !missingImage.textiles[first].images.isEmpty {
                cases.append(("Manglende bildefil", missingImage, paths))
            }
        } else {
            cases.append(("Uventet bildefil", missingImage, paths.union(["images/does-not-exist.jpeg"])))
        }

        var duplicate = original
        if let first = duplicate.textiles.first {
            duplicate.textiles.append(first)
            cases.append(("Duplisert tekstil-ID", duplicate, paths))
        } else {
            // No textiles to duplicate: test an invalid empty logical ID separately.
            cases.append(("Duplisert tekstil-ID", duplicate, paths))
        }

        var emptyID = original
        if !emptyID.textiles.isEmpty {
            emptyID.textiles[0].textileID = ""
            cases.append(("Tom tekstil-ID", emptyID, paths))
        }

        var failures: [String] = []
        for (name, document, filePaths) in cases {
            do {
                try reader.validateDocument(document, filePaths: filePaths)
                failures.append(name)
            } catch {
                // Expected: invalid semantic content is rejected.
            }
        }
        negativeJSONTestResult = failures.isEmpty && cases.count >= 3
            ? "OK: \(cases.count)/\(cases.count) ugyldige innholdsvarianter ble avvist. Ingen data importert."
            : "FEIL: " + (failures.isEmpty ? "For få testtilfeller (opprett minst ett tekstil)." : failures.joined(separator: "; "))
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw PhotoSelectionError.noData
            }

            let contentType = item.supportedContentTypes.first(where: {
                $0.preferredFilenameExtension != nil
            }) ?? .image

            diagnostic.setSelectedImage(
                data: data,
                contentType: contentType.preferredMIMEType ?? contentType.identifier,
                fileExtension: contentType.preferredFilenameExtension ?? "img"
            )
        } catch {
            diagnostic.setSelectionError(error)
        }
    }

    private func byteCount(_ value: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .file)
    }
}

private struct DiagnosticImage: View {
    let data: Data

    var body: some View {
        Group {
            #if canImport(UIKit)
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Testbilde")
            } else {
                fallback
            }
            #elseif canImport(AppKit)
            if let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Testbilde")
            } else {
                fallback
            }
            #else
            fallback
            #endif
        }
    }

    private var fallback: some View {
        Label("Bildet kunne ikke rendres", systemImage: "exclamationmark.triangle")
            .foregroundStyle(.secondary)
    }
}

private enum PhotoSelectionError: LocalizedError {
    case noData

    var errorDescription: String? {
        "Det valgte bildet kunne ikke leses som bildefil. Velg et annet bilde og prøv igjen."
    }
}

#Preview {
    DeveloperDiagnosticsView()
}

/// Shared activity presentation for backup and restore/import operations.
/// Uses the platform-native indeterminate spinner; no timer-based simulation.
private struct BackupActivityLabel: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
            Text(title)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
