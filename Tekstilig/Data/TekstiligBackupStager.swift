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
            guard Set(expected).count == expected.count, Set(provided).count == provided.count else {
                throw StagingError.duplicateImagePath("images/")
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
