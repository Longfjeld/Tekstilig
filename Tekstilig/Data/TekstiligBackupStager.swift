import Foundation

/// Writes the validated backup snapshot to a private temporary directory.
/// ZIP creation and user-facing export are separate, subsequent steps.
@MainActor
final class TekstiligBackupStager {
    enum StagingError: LocalizedError {
        case invalidImagePath(String)
        case duplicateImagePath(String)
        case imageMissing(String)

        var errorDescription: String? {
            switch self {
            case .invalidImagePath(let path): return "Ugyldig bildesti i backup: \(path)"
            case .duplicateImagePath(let path): return "Duplisert bildesti i backup: \(path)"
            case .imageMissing(let path): return "Bildedata mangler for: \(path)"
            }
        }
    }

    private static func firstDuplicate(_ paths: [String]) -> String? {
        var seen = Set<String>()
        for path in paths {
            if !seen.insert(path).inserted { return path }
        }
        return nil
    }

    private let builder: TekstiligBackupBuilder

    init(builder: TekstiligBackupBuilder) { self.builder = builder }

    func stage(_ snapshot: TekstiligBackupSnapshot) throws -> URL {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("Tekstilig-backup-stage-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        do {
            let images = root.appendingPathComponent("images", isDirectory: true)
            try fm.createDirectory(at: images, withIntermediateDirectories: true)
            let expected = snapshot.document.textiles.flatMap(\.images).map(\.backupPath)
            let provided = snapshot.imageFiles.map(\.backupPath)
            // Report the real duplicate and its source rather than a placeholder path.
            // Diagnostic only: never silently deduplicate or overwrite image data.
            let entries = snapshot.document.textiles.flatMap { textile in
                textile.images.map { image in
                    (path: image.backupPath, textileID: textile.textileID, imageID: image.imageID)
                }
            }
            if let duplicate = Self.firstDuplicate(expected) {
                let sources = entries.filter { $0.path == duplicate }
                    .map { "textileID=\($0.textileID), imageID=\($0.imageID)" }
                    .joined(separator: " | ")
                throw StagingError.duplicateImagePath(
                    "\(duplicate) [backup.json; tekstiler=\(snapshot.document.textiles.count), " +
                    "bildereferanser=\(expected.count), bildefiler=\(provided.count); \(sources)]"
                )
            }
            if let duplicate = Self.firstDuplicate(provided) {
                let sources = entries.filter { $0.path == duplicate }
                    .map { "textileID=\($0.textileID), imageID=\($0.imageID)" }
                    .joined(separator: " | ")
                throw StagingError.duplicateImagePath(
                    "\(duplicate) [imageFiles; tekstiler=\(snapshot.document.textiles.count), " +
                    "bildereferanser=\(expected.count), bildefiler=\(provided.count); " +
                    "referanser: \(sources.isEmpty ? "ingen" : sources)]"
                )
            }
            for path in expected {
                guard provided.contains(path) else { throw StagingError.imageMissing(path) }
            }
            for file in snapshot.imageFiles {
                let path = file.backupPath
                let name = String(path.dropFirst("images/".count))
                guard path.hasPrefix("images/"), !name.isEmpty,
                      name != ".", name != "..", !name.contains("/"), !name.contains("\\") else {
                    throw StagingError.invalidImagePath(path)
                }
                guard expected.contains(path) else { throw StagingError.invalidImagePath(path) }
                try file.data.write(to: images.appendingPathComponent(name), options: .atomic)
            }
            let json = try builder.encodeDocument(snapshot.document)
            try json.write(to: root.appendingPathComponent("backup.json"), options: .atomic)
            return root
        } catch {
            try? fm.removeItem(at: root)
            throw error
        }
    }
}
