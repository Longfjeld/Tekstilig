import Foundation

@MainActor
protocol TextileColorRepository {
    func fetchColors(textileID: String) async throws -> [TextileColor]
    func save(_ color: TextileColor) async throws -> TextileColor
    func delete(_ color: TextileColor) async throws
}
