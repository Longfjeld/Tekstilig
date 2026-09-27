import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class TextileImageModel {
    private(set) var primaryImage: TextileImageContent?
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var loadedTextileID: String?
    var errorMessage: String?

    private let repository: any TextileImageRepository

    init(repository: any TextileImageRepository) {
        self.repository = repository
    }

    init() {
        self.repository = CloudKitTextileImageRepository()
    }

    func loadIfNeeded(for textileID: String) async {
        guard loadedTextileID != textileID else { return }
        await load(for: textileID)
    }

    func load(for textileID: String) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            primaryImage = try await repository.fetchPrimaryImage(textileID: textileID)
            loadedTextileID = textileID
        } catch {
            errorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    func savePrimaryImage(
        textileID: String,
        data: Data,
        fileName: String,
        contentType: String
    ) async {
        guard !isSaving else { return }

        isSaving = true
        errorMessage = nil

        do {
            primaryImage = try await repository.savePrimaryImage(
                textileID: textileID,
                data: data,
                fileName: fileName,
                contentType: contentType
            )
            loadedTextileID = textileID
        } catch {
            errorMessage = Self.description(for: error)
        }

        isSaving = false
    }

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }

        return error.localizedDescription
    }
}
