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
    private(set) var materialLoadErrorMessage: String?
    private(set) var colorLoadErrorMessage: String?
    var mutationErrorMessage: String?

    var loadErrorMessage: String? {
        materialLoadErrorMessage ?? colorLoadErrorMessage
    }

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
        guard !Task.isCancelled else { return }

        isLoading = true
        materialLoadErrorMessage = nil
        colorLoadErrorMessage = nil
        // Do not mark the textile as loaded until the automatic load has
        // actually reached a stable end state. SwiftUI may cancel the .task
        // while List sections are being rebuilt.
        loadedTextileID = nil

        defer {
            isLoading = false
        }

        do {
            materials = try await fetchWithOneTransientRetry {
                try await materialRepository.fetchMaterials(textileID: textileID)
            }
        } catch {
            if Self.isCancellation(error) {
                loadedTextileID = nil
                return
            }

            Self.logCloudKitDiagnostic(error, operation: "fetchMaterials", textileID: textileID)
            materialLoadErrorMessage = Self.description(for: error)
        }

        guard !Task.isCancelled else {
            loadedTextileID = nil
            return
        }

        do {
            colors = try await fetchWithOneTransientRetry {
                try await colorRepository.fetchColors(textileID: textileID)
            }
        } catch {
            if Self.isCancellation(error) {
                loadedTextileID = nil
                return
            }

            Self.logCloudKitDiagnostic(error, operation: "fetchColors", textileID: textileID)
            colorLoadErrorMessage = Self.description(for: error)
        }

        loadedTextileID = textileID
    }

    func retryMaterials(for textileID: String) async {
        guard !isLoading else { return }

        isLoading = true
        materialLoadErrorMessage = nil
        loadedTextileID = textileID

        do {
            materials = try await materialRepository.fetchMaterials(textileID: textileID)
        } catch {
            materialLoadErrorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    func retryColors(for textileID: String) async {
        guard !isLoading else { return }

        isLoading = true
        colorLoadErrorMessage = nil
        loadedTextileID = textileID

        do {
            colors = try await colorRepository.fetchColors(textileID: textileID)
        } catch {
            colorLoadErrorMessage = Self.description(for: error)
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


    private func fetchWithOneTransientRetry<Value>(
        _ operation: () async throws -> Value
    ) async throws -> Value {
        do {
            return try await operation()
        } catch {
            guard Self.isTransientCloudKitError(error) else {
                throw error
            }

            // CloudKit can briefly report a network/service error while the app is
            // establishing its first connection, even when the device is online.
            // Retry once before presenting a persistent error to the user. Do not
            // swallow task cancellation while waiting.
            try await Task.sleep(nanoseconds: 750_000_000)
            try Task.checkCancellation()
            return try await operation()
        }
    }


    private static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        if let cloudKitError = error as? CKError,
           cloudKitError.code == .operationCancelled {
            return true
        }

        return false
    }

    private static func isTransientCloudKitError(_ error: Error) -> Bool {
        guard let cloudKitError = error as? CKError else { return false }

        switch cloudKitError.code {
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .zoneBusy, .requestRateLimited:
            return true
        default:
            return false
        }
    }

    private static func logCloudKitDiagnostic(
        _ error: Error,
        operation: String,
        textileID: String
    ) {
        print("[Tekstilig][Attributes][\(operation)] failed for textileID=\(textileID)")
        print("[Tekstilig][Attributes] errorType=\(String(reflecting: type(of: error)))")
        print("[Tekstilig][Attributes] localizedDescription=\(error.localizedDescription)")

        let nsError = error as NSError
        print("[Tekstilig][Attributes] NSError domain=\(nsError.domain) code=\(nsError.code)")

        if let cloudKitError = error as? CKError {
            print("[Tekstilig][Attributes] CKError code=\(cloudKitError.code.rawValue) name=\(String(describing: cloudKitError.code))")
            if let retryAfter = cloudKitError.retryAfterSeconds {
                print("[Tekstilig][Attributes] CKError retryAfterSeconds=\(retryAfter)")
            }

            if let partialErrors = cloudKitError.partialErrorsByItemID, !partialErrors.isEmpty {
                print("[Tekstilig][Attributes] CKError partialErrors count=\(partialErrors.count)")
                for (itemID, partialError) in partialErrors {
                    let partialNSError = partialError as NSError
                    print("[Tekstilig][Attributes] partial item=\(String(describing: itemID)) domain=\(partialNSError.domain) code=\(partialNSError.code) description=\(partialError.localizedDescription)")
                }
            }
        }

        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            let underlyingNSError = underlying as NSError
            print("[Tekstilig][Attributes] underlying domain=\(underlyingNSError.domain) code=\(underlyingNSError.code) description=\(underlying.localizedDescription)")
        }
    }

    static func description(for error: Error) -> String {
        CloudKitUserFacingError.describe(
            error,
            fallbackTitle: "Kunne ikke hente materiale og farge"
        ).message
    }
}
