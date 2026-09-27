import Foundation

@MainActor
protocol TextileRepository {
    func fetchTextiles() async throws -> [Textile]
    func save(_ textile: Textile) async throws -> Textile
}
