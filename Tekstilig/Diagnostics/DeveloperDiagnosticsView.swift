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
    @State private var interruptionReport: String?
    @State private var persistentJournalReport: String?
    @State private var retrySimulationReport: String?
    @State private var recordIdentitySimulationReport: String?
    @State private var repositoryIdentityReport: String?
    @State private var importIdentityPreflightReport: String?
    @State private var deterministicIdentityReport: String?
    @State private var combinedPreflightReport: String?
    @State private var approvedDiagnosticOperations: [String]?
    @State private var importJournalPlanReport: String?
    @State private var importJournalRecoveryReport: String?
    @State private var isCheckingCombinedPreflight = false
    @State private var imageIdentityReport: String?
    @State private var isCheckingImageIdentity = false
    @State private var isCheckingDeterministicIdentity = false
    @State private var isCheckingImportIdentity = false
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
                        Button("Simuler avbrutt import (kun i minnet)") {
                            simulateInterruptedImport()
                        }
                        .disabled(isReadingBackup || isPlanningImport || isCheckingConflicts || isCheckingStability || isAuditingIdentities || backupDiagnostic.isRunning)
                        if let interruptionReport {
                            Text(interruptionReport).font(.callout)
                        }
                        Button("Opprett lokal testjournal (ingen import)") {
                            createPersistentTestJournal()
                        }
                        .disabled(importResult == nil || isReadingBackup || backupDiagnostic.isRunning)
                        Button("Simuler ukjent serversvar og trygg gjentakelse (kun i minnet)") {
                            simulateUnknownServerOutcome()
                        }
                        .disabled(importResult == nil || isReadingBackup || backupDiagnostic.isRunning)
                        if let retrySimulationReport {
                            Text(retrySimulationReport).font(.callout)
                        }
                        Button("Kontroller eksisterende CloudKit-ID-er før import (kun lesing)") {
                            Task { await preflightExistingImportIdentities() }
                        }
                        .disabled(isCheckingImportIdentity || isReadingBackup || isPlanningImport || isCheckingConflicts || isCheckingStability || isAuditingIdentities || backupDiagnostic.isRunning)
                        if isCheckingImportIdentity {
                            BackupActivityLabel("Kontrollerer logiske ID-er mot CloudKit …")
                        }
                        if let importIdentityPreflightReport {
                            Text(importIdentityPreflightReport).font(.callout)
                        }
                        Button("Vurder stabile import-ID-er mot CloudKit (kun lesing)") {
                            Task { await assessDeterministicImportIdentities() }
                        }
                        .disabled(isCheckingDeterministicIdentity || isCheckingImportIdentity || isReadingBackup || backupDiagnostic.isRunning)
                        if isCheckingDeterministicIdentity {
                            BackupActivityLabel("Kontrollerer importidentiteter …")
                        }
                        if let deterministicIdentityReport {
                            Text(deterministicIdentityReport).font(.callout)
                        }
                        Button("Samlet importkontroll for alle fem posttyper (kun lesing)") {
                            Task { await checkCombinedImportPreflight() }
                        }
                        .disabled(isCheckingCombinedPreflight || isReadingBackup || backupDiagnostic.isRunning)
                        if isCheckingCombinedPreflight {
                            BackupActivityLabel("Kontrollerer alle fem CloudKit-posttyper …")
                        }
                        if let combinedPreflightReport {
                            Text(combinedPreflightReport).font(.callout)
                        }
                        Button("Lagre kontrollert importplan i lokal testjournal (ingen import)") {
                            saveReadOnlyImportPlanJournal()
                        }
                        .disabled(approvedDiagnosticOperations == nil || isCheckingCombinedPreflight || isReadingBackup || backupDiagnostic.isRunning)
                        if let importJournalPlanReport {
                            Text(importJournalPlanReport).font(.callout)
                        }
                        Button("Kontroller bildeidentiteter og eierskap (kun lesing)") {
                            Task { await checkImportImageIdentities() }
                        }
                        .disabled(isCheckingImageIdentity || isReadingBackup || backupDiagnostic.isRunning)
                        if isCheckingImageIdentity {
                            BackupActivityLabel("Leser bildeidentiteter fra CloudKit …")
                        }
                        if let imageIdentityReport {
                            Text(imageIdentityReport).font(.callout)
                        }
                        Button("Simuler stabile CloudKit-ID-er og eierskapskonflikt (kun i minnet)") {
                            simulateStableRecordIdentities()
                        }
                        .disabled(importResult == nil || isReadingBackup || backupDiagnostic.isRunning)
                        if let recordIdentitySimulationReport {
                            Text(recordIdentitySimulationReport).font(.callout)
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
                    // These checks do not need a selected backup and must stay visible.
                    Button("Vis faktisk CKRecord.ID-strategi (kun kontroll)") {
                        inspectRepositoryIdentityStrategy()
                    }
                    .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    if let repositoryIdentityReport {
                        Text(repositoryIdentityReport).font(.callout)
                    }
                    Button("Gjenfinn og valider importplanjournal (ingen import)") {
                        inspectReadOnlyImportPlanJournal()
                    }
                    .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    if let importJournalRecoveryReport {
                        Text(importJournalRecoveryReport).font(.callout)
                    }
                    Button("Les og slett lokal testjournal") {
                        inspectAndRemovePersistentTestJournal()
                    }
                    .disabled(isReadingBackup || backupDiagnostic.isRunning)
                    if let persistentJournalReport {
                        Text(persistentJournalReport).font(.callout)
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
                approvedDiagnosticOperations = nil
                combinedPreflightReport = nil
                importJournalPlanReport = nil
                importPlan = nil
                conflictReport = nil
                stabilityReport = nil
                interruptionReport = nil
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

    // Deterministic fault-injection simulation, entirely in memory. This does NOT
    // exercise CloudKit, CKAsset uploads, record change tags, or real rollback.
    // It establishes the intended journal ordering and fail-closed invariants.
    @MainActor
    private func simulateInterruptedImport() {
        guard let result = importResult else { return }
        // Use one representative textile from the validated backup. A backup with
        // no textiles cannot exercise the parent/child operation sequence.
        guard let textile = result.document.textiles.first else {
            interruptionReport = "Simulering AVVIST: Backup inneholder ingen tekstiler. Ingen data er endret."
            return
        }
        var operations = ["Tekstil: \(textile.textileID)"]
        operations += textile.pieces.map { "Stoffstykke: \($0.pieceID)" }
        operations += textile.materials.map { "Materiale: \($0.materialID)" }
        operations += textile.colors.map { "Farge: \($0.colorID)" }
        operations += textile.images.map { "Bilde: \($0.imageID)" }

        var passed = 0
        // Inject a failure immediately before each prospective operation, and
        // after the final operation. Journal entries are reversed for compensation.
        for failureIndex in 0...operations.count {
            var journal: [String] = []
            for operation in operations.prefix(failureIndex) {
                journal.append(operation)
            }
            let compensationOrder = Array(journal.reversed())
            // The simulated compensations remove only entries created by this
            // simulated run, leaving an empty in-memory state.
            var simulatedCreated = Set(journal)
            for operation in compensationOrder {
                simulatedCreated.remove(operation)
            }
            guard simulatedCreated.isEmpty && compensationOrder == Array(journal.reversed()) else {
                interruptionReport = "Simulering FEILET: Journalen ble ikke tømt. Skriving til CloudKit: SPERRET."
                return
            }
            passed += 1
        }
        interruptionReport = "Avbrutt import – deterministisk simulering (kun i minnet):\n" +
            "Eksempeltekstil: \(textile.textileID)\n" +
            "Planlagte operasjoner: \(operations.count) (tekstil + underposter).\n" +
            "Injiserte avbrudd testet: \(passed) (før hver operasjon og etter siste).\n" +
            "Journal tilbakeført i omvendt rekkefølge: OK i alle simuleringer.\n" +
            "Simulerte gjenstående poster etter kompensasjon: 0.\n" +
            "Skriving til CloudKit: SPERRET. Ingen data er endret.\n" +
            "BEGRENSNING: Dette er IKKE ekte CloudKit-rollback. Nettverksfeil, " +
            "ukjent resultat av serveroperasjon, CKAsset-opplasting, samtidige endringer " +
            "og opprydding etter appavslutning er IKKE testet. " +
            "Faktisk import må bruke vedvarende journal, idempotente record-ID-er " +
            "og verifisert gjenopptakelse/kompensasjon før den kan aktiveres."
    }

    // Test 220: a pure in-memory model of ambiguous server outcomes.
    // The keys below are LOGICAL operation keys, not CKRecord.ID values.
    // A real importer must separately validate deterministic CloudKit record IDs,
    // ownership and current server state before any retry or compensation.
    @MainActor
    private func simulateUnknownServerOutcome() {
        guard let textile = importResult?.document.textiles.first else {
            retrySimulationReport = "AVVIST: Velg en gyldig backup med minst ett tekstil. CloudKit: SPERRET."
            return
        }
        let operations = ["textile:" + textile.textileID] +
            textile.pieces.map { "piece:" + $0.pieceID } +
            textile.materials.map { "material:" + $0.materialID } +
            textile.colors.map { "color:" + $0.colorID } +
            textile.images.map { "image:" + $0.imageID }
        guard operations.allSatisfy({ operation in
            guard let separator = operation.firstIndex(of: ":") else { return false }
            return !operation[operation.index(after: separator)...].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else {
            retrySimulationReport = "AVVIST: Tom logisk ID i backup. CloudKit: SPERRET."
            return
        }
        guard Set(operations).count == operations.count else {
            retrySimulationReport = "AVVIST: Dupliserte logiske operasjons-ID-er. CloudKit: SPERRET."
            return
        }
        // The first attempt has an unknown acknowledgement: the server might
        // have committed the operation, or might have done nothing.
        var checkedCases = 0
        for ambiguousIndex in operations.indices {
            for serverCommitted in [false, true] {
                var simulatedServer = Set(operations.prefix(ambiguousIndex))
                if serverCommitted { simulatedServer.insert(operations[ambiguousIndex]) }
                // Reconciliation queries the simulated server before applying
                // the desired operation. A repeated operation never creates a
                // second logical record in either possible outcome.
                for operation in operations {
                    if !simulatedServer.contains(operation) {
                        simulatedServer.insert(operation)
                    }
                }
                guard simulatedServer == Set(operations) else {
                    retrySimulationReport = "FEIL: Simulert gjentakelse ga uventet tilstand. CloudKit: SPERRET."
                    return
                }
                checkedCases += 1
            }
        }
        retrySimulationReport = "Simulering av ukjent serversvar: OK.\n" +
            "Planlagte logiske operasjoner: \(operations.count).\n" +
            "Testede scenarier (lagret / ikke lagret): \(checkedCases).\n" +
            "Dupliserte logiske poster etter gjentakelse: 0.\n" +
            "Kun en modell i minnet – ingen CloudKit-ID-er eller serverresultater er verifisert.\n" +
            "Skriving til CloudKit: SPERRET."
    }

    // Test 221: local model of deterministic record names and ownership.
    // Does not call CloudKit or assert that these names are compatible with
    // record names already used by the repositories. No import is enabled.
    @MainActor
    private func simulateStableRecordIdentities() {
        guard let textile = importResult?.document.textiles.first else {
            recordIdentitySimulationReport = "AVVIST: Velg en gyldig backup med minst ett tekstil. CloudKit: SPERRET."
            return
        }
        let textileID = textile.textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        let children: [(String, String)] =
            textile.pieces.map { ("piece", $0.pieceID) } +
            textile.materials.map { ("material", $0.materialID) } +
            textile.colors.map { ("color", $0.colorID) } +
            textile.images.map { ("image", $0.imageID) }
        let entries = [("textile", textile.textileID)] + children
        guard !textileID.isEmpty, entries.allSatisfy({ !$0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            recordIdentitySimulationReport = "AVVIST: Tom logisk ID. CloudKit: SPERRET."
            return
        }
        // Length-prefix encoding avoids ambiguous separators in logical IDs.
        // This is only a candidate naming scheme, not the repository's schema.
        func candidateName(_ kind: String, _ id: String) -> String {
            "tekstilig-import-v1-\(kind.count):\(kind)-\(id.utf8.count):\(id)"
        }
        let names = entries.map { candidateName($0.0, $0.1) }
        guard Set(names).count == names.count else {
            recordIdentitySimulationReport = "AVVIST: Dupliserte kandidatidentiteter. CloudKit: SPERRET."
            return
        }
        let owner = textileID
        // Simulate the two possible outcomes of a lost acknowledgement.
        for committed in [false, true] {
            var server: [String: String] = [:]
            if committed { server[names[0]] = owner }
            for name in names {
                if let existingOwner = server[name], existingOwner != owner {
                    recordIdentitySimulationReport = "AVVIST: Uventet eier ved gjentakelse. CloudKit: SPERRET."
                    return
                }
                server[name] = owner
            }
            guard server.count == names.count else {
                recordIdentitySimulationReport = "FEIL: Gjentakelse ga uventet antall poster. CloudKit: SPERRET."
                return
            }
        }
        // A pre-existing record with the same name but different owner must
        // never be treated as successful completion of an import operation.
        var conflictingServer: [String: String] = [names[0]: "another-textile-owner"]
        let ownershipConflictBlocked = conflictingServer[names[0]] != owner
        guard ownershipConflictBlocked else {
            recordIdentitySimulationReport = "FEIL: Eierskapskonflikt ble ikke avvist. CloudKit: SPERRET."
            return
        }
        conflictingServer.removeAll()
        recordIdentitySimulationReport = "Simulering av stabile kandidat-ID-er: OK.\n" +
            "Kandidatposter: \(names.count). To utfall av ukjent serversvar: OK.\n" +
            "Kollisjon med annen eier avvist: OK.\n" +
            "Dette er IKKE eksisterende CKRecord.ID-er eller en CloudKit-kontroll. " +
            "Faktisk ID-strategi og servereierskap må avklares før skriving.\n" +
            "Skriving til CloudKit: SPERRET."
    }

    // Test 226: one consolidated read-only preflight for all five record types.
    // No reservation, atomic snapshot, or authorization to write is implied.
    @MainActor
    private func checkCombinedImportPreflight() async {
        guard let backup = importResult?.document, !isCheckingCombinedPreflight else { return }
        isCheckingCombinedPreflight = true
        combinedPreflightReport = nil
        approvedDiagnosticOperations = nil
        importJournalPlanReport = nil
        defer { isCheckingCombinedPreflight = false }
        do {
            let textiles = try await CloudKitTextileRepository().fetchTextiles()
            let pieces = try await CloudKitPieceRepository().fetchAllPieces()
            let materials = try await CloudKitTextileMaterialRepository().fetchAllMaterials()
            let colors = try await CloudKitTextileColorRepository().fetchAllColors()
            let images = try await CloudKitTextileImageRepository().fetchImageIdentitiesForImportCheck()

            let existingTextileIDs = Set(textiles.map(\.textileID))
            let incoming = backup.textiles.filter { !existingTextileIDs.contains($0.textileID) }
            let skipped = backup.textiles.count - incoming.count
            var issues: [String] = []
            var candidates: [(type: String, id: String, owner: String)] = []
            for textile in incoming {
                candidates.append(("Textile", textile.textileID, textile.textileID))
                candidates += textile.pieces.map { ("Piece", $0.pieceID, textile.textileID) }
                candidates += textile.materials.map { ("TextileMaterial", $0.materialID, textile.textileID) }
                candidates += textile.colors.map { ("TextileColor", $0.colorID, textile.textileID) }
                candidates += textile.images.map { ("TextileImage", $0.imageID, textile.textileID) }
            }
            func duplicateCount(_ values: [String]) -> Int {
                values.count - Set(values).count
            }
            let allBackupIDs = backup.textiles.map(\.textileID)
            if allBackupIDs.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) || duplicateCount(allBackupIDs) > 0 {
                issues.append("Tomme eller dupliserte tekstil-ID-er i backup")
            }
            let existing: [(String, String, String, String)] =
                textiles.map { ("Textile", $0.textileID, $0.textileID, $0.cloudRecordName ?? "") } +
                pieces.map { ("Piece", $0.pieceID, $0.textileID, $0.cloudRecordName ?? "") } +
                materials.map { ("TextileMaterial", $0.materialID, $0.textileID, $0.cloudRecordName ?? "") } +
                colors.map { ("TextileColor", $0.colorID, $0.textileID, $0.cloudRecordName ?? "") } +
                images.map { ("TextileImage", $0.imageID, $0.textileID, $0.recordName) }
            let existingKeys = existing.map { "\($0.0):\($0.1)" }
            let incomingKeys = candidates.map { "\($0.type):\($0.id)" }
            if duplicateCount(existingKeys) > 0 { issues.append("Dupliserte logiske ID-er i CloudKit") }
            if duplicateCount(incomingKeys) > 0 { issues.append("Dupliserte importkandidater") }
            if candidates.contains(where: { $0.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $0.owner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                issues.append("Tom ID eller eier i importkandidater")
            }
            if existing.contains(where: { $0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $0.2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $0.3.isEmpty }) {
                issues.append("Tom ID, eier eller recordName i CloudKit")
            }
            let existingKeySet = Set(existingKeys)
            if incomingKeys.contains(where: { existingKeySet.contains($0) }) {
                issues.append("Logisk ID-kollisjon mot CloudKit")
            }
            let recordNames = existing.map { $0.3 }
            if duplicateCount(recordNames) > 0 { issues.append("Dupliserte recordName i CloudKit") }
            let candidateNames = incomingKeys.map { key in
                "tekstilig-import-v1-" + key.utf8.map { String(format: "%02x", $0) }.joined()
            }
            let existingNameSet = Set(recordNames)
            if candidateNames.contains(where: { $0.utf8.count > 255 || existingNameSet.contains($0) }) {
                issues.append("For langt kandidatnavn eller CKRecord.recordName-kollisjon")
            }
            if issues.isEmpty {
                // This is an ephemeral, read-only snapshot of the candidate order.
                // It is invalidated whenever another backup is selected or preflight reruns.
                approvedDiagnosticOperations = candidates.map { "\($0.type):\($0.id)" }
            }
            let status = issues.isEmpty ? "FORELØPIG OK – IKKE SKRIVEKLAR" : "AVVIST"
            let counts = ["Textile", "Piece", "TextileMaterial", "TextileColor", "TextileImage"].map { type in
                "\(type): \(candidates.filter { $0.type == type }.count)"
            }.joined(separator: "; ")
            combinedPreflightReport = """
            Samlet importkontroll for alle fem posttyper (kun lesing):
            Status: \(status)
            Nye tekstiler: \(incoming.count); eksisterende hoppes over: \(skipped).
            Importkandidater: \(counts).
            CloudKit-metadata lest: \(existing.count) poster (inkludert bilder uten CKAsset).
            Konflikter: \(issues.isEmpty ? "Ingen påvist" : issues.joined(separator: "; ")).
            Kontrollen er IKKE atomisk; nye serverendringer kan oppstå etter lesingen.
            Ingen CKRecord er reservert. Journal, gjenopptakelse og skrivesikkerhet er IKKE verifisert.
            Skriving til CloudKit: SPERRET. Ingen data er endret.
            """
        } catch {
            combinedPreflightReport = "Status: AVVIST – CloudKit-lesing feilet: \(error.localizedDescription). Skriving til CloudKit: SPERRET."
        }
    }

    // Test 227: persist a read-only operation plan from the latest successful
    // combined preflight. This is NOT a write-ahead log for real CloudKit writes.
    private struct ReadOnlyImportPlanJournal: Codable {
        let schemaVersion: Int
        let journalID: UUID
        let state: String
        let operationIDs: [String]
        let completedOperationCount: Int
    }

    @MainActor
    private func saveReadOnlyImportPlanJournal() {
        guard let operations = approvedDiagnosticOperations else {
            importJournalPlanReport = "AVVIST: Kjør konfliktfri samlet importkontroll først. CloudKit: SPERRET."
            return
        }
        guard operations.count == Set(operations).count,
              operations.allSatisfy({ !$0.isEmpty && !$0.hasSuffix(":") }) else {
            importJournalPlanReport = "AVVIST: Ugyldige operasjonsidentiteter. CloudKit: SPERRET."
            return
        }
        do {
            let directory = try FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true
            ).appendingPathComponent("TekstiligImportDiagnostics", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("read-only-import-plan-v1.json")
            guard !FileManager.default.fileExists(atPath: url.path) else {
                importJournalPlanReport = "AVVIST: Lokal importplan finnes allerede og overskrives ikke. CloudKit: SPERRET."
                return
            }
            let journal = ReadOnlyImportPlanJournal(
                schemaVersion: 1, journalID: UUID(), state: "planned-read-only",
                operationIDs: operations, completedOperationCount: 0
            )
            try JSONEncoder().encode(journal).write(to: url, options: [.atomic])
            let reopened = try JSONDecoder().decode(ReadOnlyImportPlanJournal.self, from: Data(contentsOf: url))
            guard reopened.schemaVersion == 1, reopened.journalID == journal.journalID,
                  reopened.operationIDs == operations, reopened.completedOperationCount == 0,
                  reopened.state == "planned-read-only" else {
                importJournalPlanReport = "AVVIST: Kunne ikke verifisere lokal journal. Filen beholdes. CloudKit: SPERRET."
                return
            }
            importJournalPlanReport = "Lokal importplan lagret og lest tilbake: OK.\n" +
                "Operasjoner: \(operations.count). Fullførte: 0.\n" +
                "Journal-ID: \(journal.journalID.uuidString).\n" +
                "Eksisterende journal overskrives aldri. Ny plan krever manuell opprydding.\n" +
                "Planen er basert på et ikke-atomisk CloudKit-øyeblikksbilde.\n" +
                "Skriving til CloudKit: SPERRET."
        } catch {
            importJournalPlanReport = "AVVIST: Lokal journalfeil: \(error.localizedDescription). CloudKit: SPERRET."
        }
    }

    // Test 228: recover the read-only plan after process restart. No backup,
    // CloudKit connection, or prior in-memory preflight is required.
    private func readOnlyImportPlanURL() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        ).appendingPathComponent("TekstiligImportDiagnostics", isDirectory: true)
        return directory.appendingPathComponent("read-only-import-plan-v1.json")
    }

    private func validReadOnlyImportPlan(_ journal: ReadOnlyImportPlanJournal) -> Bool {
        guard journal.schemaVersion == 1,
              journal.state == "planned-read-only",
              journal.completedOperationCount == 0,
              !journal.operationIDs.isEmpty,
              journal.operationIDs.count == Set(journal.operationIDs).count else { return false }
        let allowedTypes: Set<String> = ["Textile", "Piece", "TextileMaterial", "TextileColor", "TextileImage"]
        return journal.operationIDs.allSatisfy { operation in
            let parts = operation.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            return parts.count == 2 && allowedTypes.contains(String(parts[0])) &&
                !parts[1].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    @MainActor
    private func inspectReadOnlyImportPlanJournal() {
        do {
            let url = try readOnlyImportPlanURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                importJournalRecoveryReport = "Ingen lagret importplanjournal funnet. CloudKit: SPERRET."
                return
            }
            let data = try Data(contentsOf: url)
            let journal = try JSONDecoder().decode(ReadOnlyImportPlanJournal.self, from: data)
            guard validReadOnlyImportPlan(journal) else {
                importJournalRecoveryReport = "AVVIST: Ugyldig eller ufullstendig importplanjournal. Filen beholdes. CloudKit: SPERRET."
                return
            }
            // Negative tests operate on copies only. Never modify the persisted journal.
            let invalidState = ReadOnlyImportPlanJournal(
                schemaVersion: journal.schemaVersion, journalID: journal.journalID,
                state: "writing", operationIDs: journal.operationIDs,
                completedOperationCount: journal.completedOperationCount
            )
            let invalidDuplicate = ReadOnlyImportPlanJournal(
                schemaVersion: journal.schemaVersion, journalID: journal.journalID,
                state: journal.state, operationIDs: journal.operationIDs + [journal.operationIDs[0]],
                completedOperationCount: journal.completedOperationCount
            )
            let invalidProgress = ReadOnlyImportPlanJournal(
                schemaVersion: journal.schemaVersion, journalID: journal.journalID,
                state: journal.state, operationIDs: journal.operationIDs,
                completedOperationCount: 1
            )
            guard !validReadOnlyImportPlan(invalidState),
                  !validReadOnlyImportPlan(invalidDuplicate),
                  !validReadOnlyImportPlan(invalidProgress) else {
                importJournalRecoveryReport = "FEIL: Negativ journalvalidering mislyktes. Filen beholdes. CloudKit: SPERRET."
                return
            }
            importJournalRecoveryReport = "Importplanjournal gjenfunnet og validert: OK.\n" +
                "Journal-ID: \(journal.journalID.uuidString).\n" +
                "Operasjoner: \(journal.operationIDs.count). Fullførte: 0.\n" +
                "Ugyldig status, duplikat og uventet fremdrift avvist: OK (kun minnekopier).\n" +
                "Journalfilen er beholdt. Ingen import utført.\n" +
                "Skriving til CloudKit: SPERRET."
        } catch {
            importJournalRecoveryReport = "AVVIST: Kan ikke lese/dekode importplanjournal: \(error.localizedDescription). Filen beholdes. CloudKit: SPERRET."
        }
    }

    // Test 225: image record names and ownership are read without CKAsset bytes.
    // This is a preflight diagnostic only, not authorization to import.
    @MainActor
    private func checkImportImageIdentities() async {
        guard let backup = importResult?.document, !isCheckingImageIdentity else { return }
        isCheckingImageIdentity = true
        imageIdentityReport = nil
        defer { isCheckingImageIdentity = false }
        do {
            let textiles = try await CloudKitTextileRepository().fetchTextiles()
            let images = try await CloudKitTextileImageRepository().fetchImageIdentitiesForImportCheck()
            let existingTextileIDs = Set(textiles.map(\.textileID))
            let newTextiles = backup.textiles.filter { !existingTextileIDs.contains($0.textileID) }
            let incoming = newTextiles.flatMap { textile in
                textile.images.map { (imageID: $0.imageID.trimmingCharacters(in: .whitespacesAndNewlines), textileID: textile.textileID) }
            }
            let existingNames = Set(images.map(\.recordName))
            let candidateNames = incoming.map { entry in
                "tekstilig-import-v1-" + ("TextileImage:" + entry.imageID).utf8.map { String(format: "%02x", $0) }.joined()
            }
            let emptyIDs = incoming.filter { $0.imageID.isEmpty }.count
            let duplicateIncomingIDs = incoming.count - Set(incoming.map(\.imageID)).count
            let existingImageIDs = Set(images.map(\.imageID))
            let logicalCollisions = incoming.filter { existingImageIDs.contains($0.imageID) }.count
            let recordNameCollisions = candidateNames.filter { existingNames.contains($0) }.count
            let longNames = candidateNames.filter { $0.utf8.count > 255 }.count
            let existingMissingIDs = images.filter { $0.imageID.isEmpty || $0.textileID.isEmpty || $0.recordName.isEmpty }.count
            let existingDuplicateIDs = images.count - Set(images.map(\.imageID)).count
            let existingOwners = Dictionary(grouping: images, by: \.imageID)
            let crossOwnerConflicts = incoming.filter { entry in
                (existingOwners[entry.imageID] ?? []).contains { $0.textileID != entry.textileID }
            }.count
            let blocked = emptyIDs > 0 || duplicateIncomingIDs > 0 || logicalCollisions > 0 || recordNameCollisions > 0 || longNames > 0 || existingMissingIDs > 0 || existingDuplicateIDs > 0
            imageIdentityReport = """
            Kontroll av bildeidentiteter og eierskap (kun lesing):
            Status: \(blocked ? "AVVIST" : "FORELØPIG OK – IKKE SKRIVEKLAR")
            CloudKit-bildeposter lest (alle sider): \(images.count).
            Bilder til nye tekstiler i backup: \(incoming.count); nye tekstiler: \(newTextiles.count).
            Tomme bilde-ID-er i backup: \(emptyIDs); dupliserte bilde-ID-er i backup: \(duplicateIncomingIDs).
            Kollisjon mot eksisterende logisk imageID: \(logicalCollisions); annen eier: \(crossOwnerConflicts).
            Kollisjon mot eksisterende CKRecord.recordName: \(recordNameCollisions); kandidatnavn over 255 byte: \(longNames).
            Eksisterende bildeposter med manglende ID/eier/recordName: \(existingMissingIDs); dupliserte eksisterende imageID: \(existingDuplicateIDs).
            CKAsset-data er IKKE lest. Resultatet er ikke atomisk og gir ingen skrivetillatelse.
            Skriving til CloudKit: SPERRET. Ingen data er endret.
            """
        } catch {
            imageIdentityReport = "AVVIST: CloudKit-lesing feilet: \(error.localizedDescription). Skriving til CloudKit: SPERRET."
        }
    }

    // Test 224: read-only feasibility check for a deterministic import-only
    // CKRecord.ID strategy. Existing normal save paths are not modified.
    // No CKRecord is created or saved by this diagnostic.
    @MainActor
    private func assessDeterministicImportIdentities() async {
        guard let backup = importResult?.document, !isCheckingDeterministicIdentity else { return }
        isCheckingDeterministicIdentity = true
        deterministicIdentityReport = nil
        defer { isCheckingDeterministicIdentity = false }
        do {
            let textiles = try await CloudKitTextileRepository().fetchTextiles()
            let pieces = try await CloudKitPieceRepository().fetchAllPieces()
            let materials = try await CloudKitTextileMaterialRepository().fetchAllMaterials()
            let colors = try await CloudKitTextileColorRepository().fetchAllColors()
            // The image repository exposes logical IDs but not all CKRecord.IDs.
            // This test intentionally does not claim to validate image record names.
            let existingTextileIDs = Set(textiles.map(\.textileID))
            let candidates = backup.textiles.filter { !existingTextileIDs.contains($0.textileID) }
            let existingNames = Set(textiles.compactMap(\.cloudRecordName) +
                pieces.compactMap(\.cloudRecordName) +
                materials.compactMap(\.cloudRecordName) +
                colors.compactMap(\.cloudRecordName))
            var candidateKeys: [String] = []
            var blankKeys = 0
            func append(_ type: String, _ id: String) {
                if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    blankKeys += 1
                } else {
                    candidateKeys.append("\(type):\(id)")
                }
            }
            for textile in candidates {
                append("Textile", textile.textileID)
                for piece in textile.pieces { append("Piece", piece.pieceID) }
                for material in textile.materials { append("TextileMaterial", material.materialID) }
                for color in textile.colors { append("TextileColor", color.colorID) }
            }
            // Stable, namespaced candidates; this is an evaluation only, not
            // a change to the application's current CloudKit naming strategy.
            let candidateNames = candidateKeys.map { key in
                "tekstilig-import-v1-" + key.utf8.map { String(format: "%02x", $0) }.joined()
            }
            let duplicateKeys = candidateKeys.count - Set(candidateKeys).count
            let collisions = candidateNames.filter { existingNames.contains($0) }.count
            let longNames = candidateNames.filter { $0.utf8.count > 255 }.count
            let imageCount = candidates.reduce(0) { $0 + $1.images.count }
            let blocked = blankKeys > 0 || duplicateKeys > 0 || collisions > 0 || longNames > 0
            deterministicIdentityReport = """
            Vurdering av stabile import-ID-er (kun lesing):
            Status: \(blocked ? "AVVIST" : "FORELØPIG OK – IKKE SKRIVEKLAR")
            Nye tekstiler i backup: \(candidates.count); eksisterende hoppes over: \(backup.textiles.count - candidates.count).
            Kandidater (tekstil/stykke/materiale/farge): \(candidateNames.count).
            Tomme logiske ID-er: \(blankKeys); dupliserte type/ID-par: \(duplicateKeys).
            Kollisjoner med kjente CKRecord.recordName: \(collisions); kandidatnavn over 255 byte: \(longNames).
            Bilder til nye tekstiler: \(imageCount) – bilde-recordName IKKE kontrollert.
            Kandidatnavnene er bare en teknisk vurdering. Eksisterende normal lagring bruker fortsatt servergenererte navn.
            Kontroll av eierskap, endringer mellom lesing og skriving og ukjent serversvar er IKKE løst.
            Ingen CloudKit-post er reservert; ingen import kan startes.
            Skriving til CloudKit: SPERRET. Ingen data er endret.
            """
        } catch {
            deterministicIdentityReport = "AVVIST: CloudKit-lesing feilet: \(error.localizedDescription). Skriving til CloudKit: SPERRET."
        }
    }

    // Test 223: reconcile the logical identifiers from the backup with live
    // CloudKit metadata. This is NOT a reservation, atomic snapshot, or permission
    // to write; the server may change immediately after this read-only check.
    @MainActor
    private func preflightExistingImportIdentities() async {
        guard let backup = importResult?.document, !isCheckingImportIdentity else { return }
        isCheckingImportIdentity = true
        importIdentityPreflightReport = nil
        defer { isCheckingImportIdentity = false }
        do {
            let textiles = try await CloudKitTextileRepository().fetchTextiles()
            let pieces = try await CloudKitPieceRepository().fetchAllPieces()
            let materials = try await CloudKitTextileMaterialRepository().fetchAllMaterials()
            let colors = try await CloudKitTextileColorRepository().fetchAllColors()
            let images = try await CloudKitTextileImageRepository().fetchAllImageIDsForConflictCheck()
            func duplicates(_ ids: [String]) -> Int {
                ids.count - Set(ids).count
            }
            let existingTextileIDs = textiles.map(\.textileID)
            let backupIDs = backup.textiles.map(\.textileID)
            let existing = Set(existingTextileIDs)
            let newTextiles = backup.textiles.filter { !existing.contains($0.textileID) }
            let newPieceIDs = newTextiles.flatMap { $0.pieces.map(\.pieceID) }
            let newMaterialIDs = newTextiles.flatMap { $0.materials.map(\.materialID) }
            let newColorIDs = newTextiles.flatMap { $0.colors.map(\.colorID) }
            let newImageIDs = newTextiles.flatMap { $0.images.map(\.imageID) }
            let collisions = [
                newPieceIDs.filter { Set(pieces.map(\.pieceID)).contains($0) }.count,
                newMaterialIDs.filter { Set(materials.map(\.materialID)).contains($0) }.count,
                newColorIDs.filter { Set(colors.map(\.colorID)).contains($0) }.count,
                newImageIDs.filter { Set(images).contains($0) }.count
            ]
            let missingRecordNames = textiles.filter { ($0.cloudRecordName ?? "").isEmpty }.count +
                pieces.filter { ($0.cloudRecordName ?? "").isEmpty }.count +
                materials.filter { ($0.cloudRecordName ?? "").isEmpty }.count +
                colors.filter { ($0.cloudRecordName ?? "").isEmpty }.count
            let duplicateLive = [duplicates(existingTextileIDs), duplicates(pieces.map(\.pieceID)),
                                 duplicates(materials.map(\.materialID)), duplicates(colors.map(\.colorID)),
                                 duplicates(images)]
            let missingIDs = backupIDs.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
            let blocked = duplicateLive.contains(where: { $0 > 0 }) || duplicates(backupIDs) > 0 ||
                missingIDs > 0 || missingRecordNames > 0 || collisions.contains(where: { $0 > 0 })
            importIdentityPreflightReport = "Importidentiteter (live metadata, kun lesing):\n" +
                "Status: \(blocked ? "AVVIST" : "FORELØPIG OK – IKKE SKRIVEKLAR")\n" +
                "Nye tekstiler: \(newTextiles.count); eksisterende tekstiler hoppes over: \(backup.textiles.count - newTextiles.count).\n" +
                "Dupliserte logiske ID-er i CloudKit (tekstil/stykke/materiale/farge/bilde): \(duplicateLive.map(String.init).joined(separator: "/")).\n" +
                "Dupliserte tekstil-ID-er i backup: \(duplicates(backupIDs)); tomme: \(missingIDs).\n" +
                "Eksisterende poster uten recordName (unntatt bilder): \(missingRecordNames).\n" +
                "Kollisjoner for nye underposter (stykke/materiale/farge/bilde): \(collisions.map(String.init).joined(separator: "/")).\n" +
                "Eksisterende recordName beholdes; nye recordName kan ikke utledes fra logisk ID. " +
                "Bilde-recordName og CKAsset er ikke verifisert her. " +
                "Dette er ingen atomisk snapshot eller tillatelse til import.\n" +
                "Skriving til CloudKit: SPERRET. Ingen data er endret."
        } catch {
            importIdentityPreflightReport = "AVVIST: CloudKit-lesing feilet: \(error.localizedDescription). Skriving til CloudKit: SPERRET."
        }
    }

    // Test 222: a read-only architectural diagnostic documenting the actual
    // repository save branches. No CloudKit access or mutation is performed.
    // The findings below were checked against the five repository save methods
    // in the 0067 source tree. They are not a runtime verification of server IDs.
    @MainActor
    private func inspectRepositoryIdentityStrategy() {
        repositoryIdentityReport = """
        Faktisk CKRecord.ID-strategi i appens eksisterende repositories:
        Textile, Piece, TextileMaterial, TextileColor, TextileImage: samme mønster.
        • Med cloudRecordName: hent eksisterende CKRecord.ID(recordName:) og oppdater posten.
        • Uten cloudRecordName: opprett CKRecord(recordType:) uten eksplisitt recordID; CloudKit tildeler recordName ved lagring.
        • Logisk textileID / pieceID / materialID / colorID / imageID lagres som egne felt, ikke som CKRecord.ID.
        • Etter lagring leses recordID.recordName tilbake i modellen.

        Konsekvens for import:
        Kandidat-ID-ene fra test 221 er IKKE appens nåværende ID-strategi.
        Backupens logiske ID alene kan ikke brukes til å anta et eksisterende CKRecord.ID.
        Å gjenta en opprettelse uten kjent recordName kan opprette duplikat.
        Før faktisk import må vi velge og implementere en stabil opprettelsesidentitet, kontrollere eksisterende logiske ID-er på serveren og avvise eierskapskonflikter.
        Denne rapporten beskriver inspisert kildekode, ikke en live CloudKit-verifikasjon.
        Skriving til CloudKit: SPERRET.
        """
    }

    // Local-only test journal. This is NOT an import transaction or a recovery
    // implementation. No CloudKit record is ever written by these functions.
    private struct LocalImportTestJournal: Codable {
        let schemaVersion: Int
        let journalID: UUID
        let textileID: String
        let operationIDs: [String]
        let completedOperationCount: Int
        let state: String
    }

    private func localJournalURL() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        ).appendingPathComponent("TekstiligImportDiagnostics", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("interrupted-import-test.json")
    }

    @MainActor
    private func createPersistentTestJournal() {
        guard let textile = importResult?.document.textiles.first else {
            persistentJournalReport = "AVVIST: Velg en gyldig backup med minst ett tekstil."
            return
        }
        do {
            let url = try localJournalURL()
            // Never overwrite an existing journal: it may be evidence of an
            // interrupted previous diagnostic run.
            guard !FileManager.default.fileExists(atPath: url.path) else {
                persistentJournalReport = "AVVIST: En testjournal finnes allerede. Les og slett den først. Ingen data er endret."
                return
            }
            let operations = ["textile:" + textile.textileID] +
                textile.pieces.map { "piece:" + $0.pieceID } +
                textile.materials.map { "material:" + $0.materialID } +
                textile.colors.map { "color:" + $0.colorID } +
                textile.images.map { "image:" + $0.imageID }
            let journal = LocalImportTestJournal(
                schemaVersion: 1, journalID: UUID(), textileID: textile.textileID,
                operationIDs: operations, completedOperationCount: 0,
                state: "interrupted-test-only"
            )
            let data = try JSONEncoder().encode(journal)
            try data.write(to: url, options: [.atomic])
            let readBack = try JSONDecoder().decode(LocalImportTestJournal.self, from: Data(contentsOf: url))
            guard readBack.journalID == journal.journalID && readBack.operationIDs == operations else {
                persistentJournalReport = "FEIL: Journalen kunne ikke verifiseres etter lagring. CloudKit: SPERRET."
                return
            }
            persistentJournalReport = "Lokal testjournal opprettet og lest tilbake: OK.\n" +
                "Journal-ID: \(journal.journalID.uuidString)\n" +
                "Planlagte operasjoner: \(operations.count). Fullførte: 0.\n" +
                "Avbrudd simulert ved lagret status. Avslutt appen helt og åpne den igjen. " +
                "Trykk deretter «Les og slett lokal testjournal».\n" +
                "Skriving til CloudKit: SPERRET."
        } catch {
            persistentJournalReport = "AVVIST: Kunne ikke lagre lokal testjournal: \(error.localizedDescription). CloudKit: SPERRET."
        }
    }

    @MainActor
    private func inspectAndRemovePersistentTestJournal() {
        do {
            let url = try localJournalURL()
            guard FileManager.default.fileExists(atPath: url.path) else {
                persistentJournalReport = "Ingen lokal testjournal funnet. CloudKit: SPERRET."
                return
            }
            // Decode and validate before deleting. Corrupt journal must remain
            // available for diagnostics rather than silently disappearing.
            let journal = try JSONDecoder().decode(LocalImportTestJournal.self, from: Data(contentsOf: url))
            guard journal.schemaVersion == 1,
                  journal.state == "interrupted-test-only",
                  journal.completedOperationCount == 0,
                  !journal.operationIDs.isEmpty,
                  journal.operationIDs.first == "textile:" + journal.textileID else {
                persistentJournalReport = "AVVIST: Uventet journalinnhold. Filen beholdes. CloudKit: SPERRET."
                return
            }
            try FileManager.default.removeItem(at: url)
            persistentJournalReport = "Journal gjenfunnet etter ny lesing: OK.\n" +
                "Journal-ID: \(journal.journalID.uuidString).\n" +
                "Ufullført testimport oppdaget; fullførte operasjoner: 0.\n" +
                "Lokal testjournal slettet: OK.\n" +
                "Ingen import eller tilbakeføring er utført. Skriving til CloudKit: SPERRET."
        } catch {
            persistentJournalReport = "AVVIST: Kunne ikke lese/slette journal: \(error.localizedDescription). CloudKit: SPERRET."
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
