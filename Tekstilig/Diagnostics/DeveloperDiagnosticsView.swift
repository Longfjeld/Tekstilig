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
    @State private var importResult: TekstiligBackupReader.Result?
    @State private var importError: String?
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
                    if let importError {
                        Text(importError).foregroundStyle(.orange)
                    }
                    if validatedZIPData != nil {
                        Button("Test avvisning av ugyldige ZIP-filer") {
                            runNegativeZIPTests()
                        }
                        .disabled(isReadingBackup || backupDiagnostic.isRunning)
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
                validatedZIPData = nil
                negativeZIPTestResult = nil
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
