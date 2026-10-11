import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class TextileLibraryModel {
    private(set) var textiles: [Textile] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorTitle: String?
    var errorMessage: String?

    private let repository: any TextileRepository

    init(repository: any TextileRepository) {
        self.repository = repository
    }

    init() {
        self.repository = CloudKitTextileRepository()
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorTitle = nil
        errorMessage = nil

        do {
            textiles = try await repository.fetchTextiles()
            hasLoaded = true
        } catch {
            let presentation = CloudKitUserFacingError.describe(
                error,
                fallbackTitle: "Kunne ikke hente tekstiler"
            )
            errorTitle = presentation.title
            errorMessage = presentation.message
        }

        isLoading = false
    }

    @discardableResult
    func save(_ textile: Textile) async throws -> Textile {
        var normalized = textile
        normalized.name = textile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.category = textile.category.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.locationArea = textile.locationArea.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.locationShelf = textile.locationShelf.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.locationContainer = textile.locationContainer.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.notes = textile.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.care = textile.care.normalized()
        normalized.stretch = textile.stretch.normalized()
        normalized.shrinkage = textile.shrinkage.normalized()

        guard !normalized.name.isEmpty else {
            throw TextileLibraryError.nameRequired
        }

        let saved = try await repository.save(normalized)
        upsert(saved)
        errorMessage = nil
        return saved
    }

    func textile(withIdentity identity: String) -> Textile? {
        textiles.first { $0.id == identity }
    }

    private func upsert(_ textile: Textile) {
        if let index = textiles.firstIndex(where: { $0.id == textile.id }) {
            textiles[index] = textile
        } else {
            textiles.append(textile)
        }

        textiles.sort {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }


}

private enum TextileLibraryError: LocalizedError {
    case nameRequired

    var errorDescription: String? {
        switch self {
        case .nameRequired:
            return "Navn må fylles ut før tekstilet kan lagres."
        }
    }
}
