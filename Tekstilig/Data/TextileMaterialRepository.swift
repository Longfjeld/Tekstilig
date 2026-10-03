import Foundation

@MainActor
protocol TextileMaterialRepository {
    func fetchMaterials(textileID: String) async throws -> [TextileMaterial]
    func fetchAllMaterials() async throws -> [TextileMaterial]
    func save(_ material: TextileMaterial) async throws -> TextileMaterial
    func delete(_ material: TextileMaterial) async throws
}
