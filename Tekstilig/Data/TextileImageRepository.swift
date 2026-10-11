import Foundation

@MainActor
protocol TextileImageRepository {
    func fetchPrimaryImage(textileID: String) async throws -> TextileImageContent?
    func fetchPrimaryImageTextileIDs() async throws -> Set<String>
    func savePrimaryImage(
        textileID: String,
        data: Data,
        fileName: String,
        contentType: String
    ) async throws -> TextileImageContent
}
