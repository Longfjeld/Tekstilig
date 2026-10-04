import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class PieceInventoryModel {
    private(set) var pieces: [Piece] = []
    private(set) var isLoading = false
    private(set) var loadedTextileID: String?
    var errorMessage: String?

    private let repository: any PieceRepository

    init(repository: any PieceRepository) {
        self.repository = repository
    }

    init() {
        self.repository = CloudKitPieceRepository()
    }

    func loadIfNeeded(for textileID: String) async {
        guard loadedTextileID != textileID else { return }
        await load(for: textileID)
    }

    func load(for textileID: String) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            pieces = try await repository.fetchPieces(textileID: textileID)
            loadedTextileID = textileID
        } catch {
            errorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    @discardableResult
    func save(_ piece: Piece) async throws -> Piece {
        var normalized = piece
        normalized.project = piece.project.trimmingCharacters(in: .whitespacesAndNewlines)

        let saved = try await repository.save(normalized)
        upsert(saved)
        errorMessage = nil
        NotificationCenter.default.post(
            name: .tekstiligPieceDidChange,
            object: saved,
            userInfo: ["deleted": false]
        )
        return saved
    }

    func delete(_ piece: Piece) async throws {
        try await repository.delete(piece)
        pieces.removeAll { $0.id == piece.id }
        errorMessage = nil
        NotificationCenter.default.post(
            name: .tekstiligPieceDidChange,
            object: piece,
            userInfo: ["deleted": true]
        )
    }

    private func upsert(_ piece: Piece) {
        if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
            pieces[index] = piece
        } else {
            pieces.append(piece)
        }

        pieces.sort {
            if $0.lengthCm != $1.lengthCm {
                return $0.lengthCm > $1.lengthCm
            }
            if $0.widthCm != $1.widthCm {
                return $0.widthCm > $1.widthCm
            }
            return $0.pieceID.localizedCaseInsensitiveCompare($1.pieceID) == .orderedAscending
        }
    }

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }

        return error.localizedDescription
    }
}


extension Notification.Name {
    static let tekstiligPieceDidChange = Notification.Name("Tekstilig.PieceDidChange")
}
