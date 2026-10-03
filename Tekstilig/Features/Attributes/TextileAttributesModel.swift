import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class TextileAttributesModel {
    private(set) var materials: [TextileMaterial] = []
    private(set) var colors: [TextileColor] = []
    private(set) var isLoading = false
    private(set) var loadedTextileID: String?
    private(set) var loadErrorMessage: String?
    var mutationErrorMessage: String?

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

    func loadIfNeeded(for textileID: String) async {
        guard loadedTextileID != textileID else { return }
        await load(for: textileID)
    }

    func load(for textileID: String) async {
        guard !isLoading else { return }

        isLoading = true
        loadErrorMessage = nil

        do {
            materials = try await materialRepository.fetchMaterials(textileID: textileID)
            colors = try await colorRepository.fetchColors(textileID: textileID)
            loadedTextileID = textileID
        } catch {
            loadErrorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    @discardableResult
    func saveMaterial(_ material: TextileMaterial) async throws -> TextileMaterial {
        let saved = try await materialRepository.save(material)
        upsertMaterial(saved)
        mutationErrorMessage = nil
        return saved
    }

    func deleteMaterial(_ material: TextileMaterial) async throws {
        try await materialRepository.delete(material)
        materials.removeAll { $0.id == material.id }
        mutationErrorMessage = nil
    }

    @discardableResult
    func saveColor(_ color: TextileColor) async throws -> TextileColor {
        let saved = try await colorRepository.save(color)
        upsertColor(saved)
        mutationErrorMessage = nil
        return saved
    }

    func deleteColor(_ color: TextileColor) async throws {
        try await colorRepository.delete(color)
        colors.removeAll { $0.id == color.id }
        mutationErrorMessage = nil
    }

    private func upsertMaterial(_ material: TextileMaterial) {
        if let index = materials.firstIndex(where: { $0.id == material.id }) {
            materials[index] = material
        } else {
            materials.append(material)
        }

        materials.sort {
            $0.material.localizedCaseInsensitiveCompare($1.material) == .orderedAscending
        }
    }

    private func upsertColor(_ color: TextileColor) {
        if let index = colors.firstIndex(where: { $0.id == color.id }) {
            colors[index] = color
        } else {
            colors.append(color)
        }

        colors.sort {
            if $0.group != $1.group {
                return $0.group.localizedCaseInsensitiveCompare($1.group) == .orderedAscending
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }
        return error.localizedDescription
    }
}
