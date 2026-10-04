import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class PieceLibraryIndex {
    private(set) var piecesByTextileID: [String: [Piece]] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    private let repository: any PieceRepository

    init(repository: any PieceRepository) {
        self.repository = repository
    }

    init() {
        self.repository = CloudKitPieceRepository()
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let pieces = try await repository.fetchAllPieces()
            piecesByTextileID = Dictionary(grouping: pieces, by: \.textileID)
            hasLoaded = true
        } catch {
            errorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    func pieces(for textileID: String) -> [Piece] {
        piecesByTextileID[textileID] ?? []
    }

    func upsert(_ piece: Piece) {
        var pieces = piecesByTextileID[piece.textileID] ?? []

        if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
            pieces[index] = piece
        } else {
            pieces.append(piece)
        }

        piecesByTextileID[piece.textileID] = Self.sortedPieces(pieces)
    }

    func remove(_ piece: Piece) {
        var pieces = piecesByTextileID[piece.textileID] ?? []
        pieces.removeAll { $0.id == piece.id }
        piecesByTextileID[piece.textileID] = Self.sortedPieces(pieces)
    }

    private static func sortedPieces(_ pieces: [Piece]) -> [Piece] {
        pieces.sorted {
            if $0.availableLengthCm != $1.availableLengthCm {
                return $0.availableLengthCm > $1.availableLengthCm
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
