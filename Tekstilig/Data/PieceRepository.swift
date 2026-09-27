import Foundation

@MainActor
protocol PieceRepository {
    func fetchPieces(textileID: String) async throws -> [Piece]
    func save(_ piece: Piece) async throws -> Piece
    func delete(_ piece: Piece) async throws
}
