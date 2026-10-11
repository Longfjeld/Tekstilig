import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class TextileLibraryImageIndex {
    private(set) var primaryImageTextileIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?

    private let repository: any TextileImageRepository

    init(repository: any TextileImageRepository) {
        self.repository = repository
    }

    init() {
        self.repository = CloudKitTextileImageRepository()
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
            primaryImageTextileIDs = try await repository.fetchPrimaryImageTextileIDs()
            hasLoaded = true
        } catch {
            errorMessage = Self.description(for: error)
        }

        isLoading = false
    }

    func hasPrimaryImage(for textileID: String) -> Bool {
        primaryImageTextileIDs.contains(textileID)
    }

    private static func description(for error: Error) -> String {
        if let cloudKitError = error as? CKError {
            return "CloudKit-feil \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }
        return error.localizedDescription
    }
}
