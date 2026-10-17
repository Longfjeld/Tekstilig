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
        defer { isRunning = false }

        do {
            let snapshot = try await builder.buildSnapshot()
            let data = try builder.encodeDocument(snapshot.document)
            let decoded = try builder.decodeDocument(data)

            guard decoded == snapshot.document else {
                throw BackupDiagnosticError.roundTripMismatch
            }

            textileCount = decoded.textiles.count
            materialCount = decoded.textiles.reduce(0) { $0 + $1.materials.count }
            colorCount = decoded.textiles.reduce(0) { $0 + $1.colors.count }
            pieceCount = decoded.textiles.reduce(0) { $0 + $1.pieces.count }
            imageCount = decoded.textiles.reduce(0) { $0 + $1.images.count }
            imageByteCount = snapshot.imageFiles.reduce(0) { $0 + $1.data.count }
            jsonByteCount = data.count
            completedSuccessfully = true
        } catch {
            errorMessage = CloudKitUserFacingError.describe(error, fallbackTitle: "Kunne ikke bygge backup").message
        }
    }
}

private enum BackupDiagnosticError: LocalizedError {
    case roundTripMismatch

    var errorDescription: String? {
        "Backup-JSON kunne ikke leses tilbake identisk etter serialisering."
    }
}
