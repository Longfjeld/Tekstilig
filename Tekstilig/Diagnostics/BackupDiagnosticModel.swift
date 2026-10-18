import Foundation
import Observation

@MainActor
@Observable
final class BackupDiagnosticModel {
    var isRunning = false
    var errorMessage: String?
    var completedSuccessfully = false
    var textileCount = 0
    var materialCount = 0
    var colorCount = 0
    var pieceCount = 0
    var imageCount = 0
    var imageByteCount = 0
    var jsonByteCount = 0
    var stagedSuccessfully = false
    var zipSuccessfully = false
    var zipByteCount = 0
    var exportDocument: BackupExportDocument?

    private let builder: TekstiligBackupBuilder

    init(builder: TekstiligBackupBuilder) {
        self.builder = builder
    }

    convenience init() {
        self.init(builder: TekstiligBackupBuilder())
    }

    func run() async {
        guard !isRunning else { return }

        isRunning = true
        errorMessage = nil
        completedSuccessfully = false
        stagedSuccessfully = false
        zipSuccessfully = false
        exportDocument = nil
        defer { isRunning = false }

        do {
            let snapshot = try await builder.buildSnapshot()
            let data = try builder.encodeDocument(snapshot.document)
            let decoded = try builder.decodeDocument(data)

            // Compare the canonical, serialized representation rather than raw Date values.
            // ISO 8601 JSON uses millisecond precision; CloudKit Date can be finer.
            let reencoded = try builder.encodeDocument(decoded)
            guard reencoded == data else {
                throw BackupDiagnosticError.roundTripMismatch(
                    Self.firstDifference(original: data, roundTripped: reencoded)
                )
            }

            textileCount = decoded.textiles.count
            materialCount = decoded.textiles.reduce(0) { $0 + $1.materials.count }
            colorCount = decoded.textiles.reduce(0) { $0 + $1.colors.count }
            pieceCount = decoded.textiles.reduce(0) { $0 + $1.pieces.count }
            imageCount = decoded.textiles.reduce(0) { $0 + $1.images.count }
            imageByteCount = snapshot.imageFiles.reduce(0) { $0 + $1.data.count }
            jsonByteCount = data.count
            // Stage and verify actual files; do not retain temporary backup data.
            let staged = try TekstiligBackupStager(builder: builder).stage(snapshot)
            defer { try? FileManager.default.removeItem(at: staged) }
            let diskJSON = try Data(contentsOf: staged.appendingPathComponent("backup.json"))
            guard diskJSON == data else { throw BackupStagingDiagnosticError.jsonMismatch }
            for image in snapshot.imageFiles {
                let diskImage = try Data(contentsOf: staged.appendingPathComponent(image.backupPath))
                guard diskImage == image.data else { throw BackupStagingDiagnosticError.imageMismatch(image.backupPath) }
            }
            stagedSuccessfully = true
            let zipURL = try TekstiligBackupZIP().create(from: staged)
            defer { try? FileManager.default.removeItem(at: zipURL) }
            let zipData = try Data(contentsOf: zipURL)
            // Verify archive entries and their CRCs before presenting an export.
            var expectedFiles = ["backup.json": data]
            for image in snapshot.imageFiles { expectedFiles[image.backupPath] = image.data }
            try BackupZIPVerifier.verify(zipData, expected: expectedFiles)
            zipByteCount = zipData.count
            zipSuccessfully = true
            exportDocument = BackupExportDocument(data: zipData)
            completedSuccessfully = true
        } catch {
            errorMessage = CloudKitUserFacingError.describe(error, fallbackTitle: "Kunne ikke bygge backup").message
        }
    }

    private static func firstDifference(original: Data, roundTripped: Data) -> String {
        // JSON is UTF-8 and both encoders use sorted keys and pretty printing.
        let left = Array(original)
        let right = Array(roundTripped)
        let offset = zip(left, right).enumerated().first { _, pair in
            pair.0 != pair.1
        }?.offset ?? min(left.count, right.count)
        let start = max(0, offset - 45)
        let leftEnd = min(left.count, offset + 85)
        let rightEnd = min(right.count, offset + 85)
        let before = String(decoding: left[start..<leftEnd], as: UTF8.self)
        let after = String(decoding: right[start..<rightEnd], as: UTF8.self)
        return "Avvik ved byte \(offset) (før: \(left.count) B, etter: \(right.count) B). Før: \(before). Etter: \(after)."
    }
}

private enum BackupDiagnosticError: LocalizedError {
    case roundTripMismatch(String)

    var errorDescription: String? {
        switch self {
        case .roundTripMismatch(let detail):
            return "Backup-JSON endret seg etter decode/encode. \(detail)"
        }
    }
}

private enum BackupStagingDiagnosticError: LocalizedError {
    case jsonMismatch
    case imageMismatch(String)
    var errorDescription: String? {
        switch self {
        case .jsonMismatch: return "backup.json er ulik etter skriving til disk."
        case .imageMismatch(let path): return "Bildefilen er ulik etter skriving: \(path)"
        }
    }
}
