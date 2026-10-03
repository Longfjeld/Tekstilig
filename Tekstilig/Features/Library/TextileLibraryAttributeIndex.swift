import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class TextileLibraryAttributeIndex {
    private(set) var materialsByTextileID: [String: [TextileMaterial]] = [:]
    private(set) var colorsByTextileID: [String: [TextileColor]] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    private let materialRepository: any TextileMaterialRepository
    private let colorRepository: any TextileColorRepository

    init(
        materialRepository: any TextileMaterialRepository,
        colorRepository: any TextileColorRepository
    ) {
        self.materialRepository = materialRepository
        self.colorRepository = colorRepository
    }

    init() {
        self.materialRepository = CloudKitTextileMaterialRepository()
        self.colorRepository = CloudKitTextileColorRepository()
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
            let materials = try await materialRepository.fetchAllMaterials()
            let colors = try await colorRepository.fetchAllColors()

            materialsByTextileID = Dictionary(grouping: materials, by: \.textileID)
            colorsByTextileID = Dictionary(grouping: colors, by: \.textileID)
            hasLoaded = true
        } catch {
            errorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    func materials(for textileID: String) -> [TextileMaterial] {
        materialsByTextileID[textileID] ?? []
    }

    func colors(for textileID: String) -> [TextileColor] {
        colorsByTextileID[textileID] ?? []
    }

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }
        return error.localizedDescription
    }
}
