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

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }
        return error.localizedDescription
    }
}
