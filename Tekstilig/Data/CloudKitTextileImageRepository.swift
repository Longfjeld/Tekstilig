import CloudKit
import Foundation

@MainActor
final class CloudKitTextileImageRepository: TextileImageRepository {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"

    private static let recordType = "TextileImage"
    private static let diagnosticRecordNames: Set<String> = [
        "swiftui-poc-textile-image-v1"
    ]

    private let database: CKDatabase

    init(container: CKContainer? = nil) {
        let resolvedContainer = container ?? CKContainer(identifier: Self.containerIdentifier)
        database = resolvedContainer.privateCloudDatabase
    }

    func fetchPrimaryImage(textileID: String) async throws -> TextileImageContent? {
        let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileImageRepositoryError.missingRequiredField("textileId")
        }

        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(format: "textileId == %@", normalizedTextileID)
        )

        let desiredKeys = [
            "imageId",
            "textileId",
            "type",
            "primary",
            "fileName",
            "contentType",
            "imageAsset"
        ]

        var candidates: [(record: CKRecord, image: TextileImageContent)] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let response: (
                matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
                queryCursor: CKQueryOperation.Cursor?
            )

            if let cursor {
                response = try await database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: desiredKeys,
                    resultsLimit: 100
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: desiredKeys,
                    resultsLimit: 100
                )
            }

            for (_, result) in response.matchResults {
                switch result {
                case .success(let record):
                    guard !Self.diagnosticRecordNames.contains(record.recordID.recordName) else {
                        continue
                    }

                    let image = try Self.content(from: record)
                    if image.image.isPrimary {
                        candidates.append((record: record, image: image))
                    }

                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        // Dersom eldre data ved en feil inneholder mer enn ett hovedbilde,
        // bruk den sist endrede recorden uten å skjule/slette data automatisk.
        return candidates
            .sorted {
                ($0.record.modificationDate ?? .distantPast) > ($1.record.modificationDate ?? .distantPast)
            }
            .first?
            .image
    }

    func savePrimaryImage(
        textileID: String,
        data: Data,
        fileName: String,
        contentType: String
    ) async throws -> TextileImageContent {
        let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileImageRepositoryError.missingRequiredField("textileId")
        }
        guard !data.isEmpty else {
            throw CloudKitTextileImageRepositoryError.emptyImageData
        }

        let normalizedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedContentType = contentType.trimmingCharacters(in: .whitespacesAndNewlines)

        let existing = try await fetchPrimaryImage(textileID: normalizedTextileID)
        let image = existing?.image ?? TextileImage.newPrimaryDraft(
            textileID: normalizedTextileID,
            fileName: normalizedFileName,
            contentType: normalizedContentType
        )

        let record: CKRecord
        if let cloudRecordName = image.cloudRecordName {
            record = try await database.record(
                for: CKRecord.ID(recordName: cloudRecordName)
            )
            guard record.recordType == Self.recordType else {
                throw CloudKitTextileImageRepositoryError.unexpectedRecordType(record.recordType)
            }
        } else {
            record = CKRecord(recordType: Self.recordType)
        }

        let safeExtension = Self.safeExtension(from: normalizedFileName)
        let temporaryFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tekstilig-image-\(UUID().uuidString)")
            .appendingPathExtension(safeExtension)

        try data.write(to: temporaryFileURL, options: .atomic)
        defer {
            try? FileManager.default.removeItem(at: temporaryFileURL)
        }

        record["imageId"] = image.imageID as CKRecordValue
        record["textileId"] = normalizedTextileID as CKRecordValue
        record["type"] = image.type as CKRecordValue
        record["primary"] = NSNumber(value: 1)
        record["fileName"] = normalizedFileName as CKRecordValue
        record["contentType"] = normalizedContentType as CKRecordValue
        record["imageAsset"] = CKAsset(fileURL: temporaryFileURL)

        let savedRecord = try await database.save(record)

        // Les Asset-data mens CloudKit staging-URL-en er gyldig.
        let fetchedRecord = try await database.record(for: savedRecord.recordID)
        return try Self.content(from: fetchedRecord)
    }

    private static func content(from record: CKRecord) throws -> TextileImageContent {
        guard record.recordType == recordType else {
            throw CloudKitTextileImageRepositoryError.unexpectedRecordType(record.recordType)
        }

        guard let imageID = record["imageId"] as? String,
              !imageID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitTextileImageRepositoryError.missingRequiredField("imageId")
        }
        guard let textileID = record["textileId"] as? String,
              !textileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitTextileImageRepositoryError.missingRequiredField("textileId")
        }
        guard let asset = record["imageAsset"] as? CKAsset else {
            throw CloudKitTextileImageRepositoryError.missingAsset
        }
        guard let fileURL = asset.fileURL else {
            throw CloudKitTextileImageRepositoryError.missingAssetFileURL
        }

        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else {
            throw CloudKitTextileImageRepositoryError.emptyImageData
        }

        let image = TextileImage(
            imageID: imageID,
            cloudRecordName: record.recordID.recordName,
            textileID: textileID,
            type: record["type"] as? String ?? "fabric",
            isPrimary: ((record["primary"] as? NSNumber)?.intValue ?? 0) == 1,
            fileName: record["fileName"] as? String ?? "image.bin",
            contentType: record["contentType"] as? String ?? "application/octet-stream"
        )

        return TextileImageContent(image: image, data: data)
    }

    private static func safeExtension(from fileName: String) -> String {
        let raw = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        let filtered = raw.filter { $0.isLetter || $0.isNumber }
        return filtered.isEmpty ? "bin" : filtered
    }
}

private enum CloudKitTextileImageRepositoryError: LocalizedError {
    case unexpectedRecordType(String)
    case missingRequiredField(String)
    case missingAsset
    case missingAssetFileURL
    case emptyImageData

    var errorDescription: String? {
        switch self {
        case .unexpectedRecordType(let actual):
            return "Forventet CloudKit record type TextileImage, men fikk \(actual)."
        case .missingRequiredField(let field):
            return "En TextileImage-record mangler det påkrevde feltet \(field)."
        case .missingAsset:
            return "TextileImage-recorden mangler imageAsset."
        case .missingAssetFileURL:
            return "CloudKit returnerte imageAsset uten en tilgjengelig lokal fil-URL."
        case .emptyImageData:
            return "Bildedataene er tomme."
        }
    }
}
