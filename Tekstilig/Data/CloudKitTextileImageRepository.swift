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

    func fetchPrimaryImageTextileIDs() async throws -> Set<String> {
        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(value: true)
        )

        var textileIDs: Set<String> = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let response: (
                matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
                queryCursor: CKQueryOperation.Cursor?
            )

            if let cursor {
                response = try await database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: ["textileId", "primary"],
                    resultsLimit: 100
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: ["textileId", "primary"],
                    resultsLimit: 100
                )
            }

            for (_, result) in response.matchResults {
                switch result {
                case .success(let record):
                    guard !Self.diagnosticRecordNames.contains(record.recordID.recordName),
                          ((record["primary"] as? NSNumber)?.intValue ?? 0) == 1,
                          let textileID = record["textileId"] as? String else {
                        continue
                    }

                    let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !normalizedTextileID.isEmpty {
                        textileIDs.insert(normalizedTextileID)
                    }

                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return textileIDs
    }

    // Read only logical image IDs; never request CKAsset data. All pages are required.
    func fetchAllImageIDsForConflictCheck() async throws -> [String] {
        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        var cursor: CKQueryOperation.Cursor?
        var ids: [String] = []
        repeat {
            let response: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let cursor {
                response = try await database.records(continuingMatchFrom: cursor, desiredKeys: ["imageId"], resultsLimit: 100)
            } else {
                response = try await database.records(matching: query, inZoneWith: nil, desiredKeys: ["imageId"], resultsLimit: 100)
            }
            for (_, result) in response.matchResults {
                switch result {
                case .failure(let error): throw error
                case .success(let record):
                    if Self.diagnosticRecordNames.contains(record.recordID.recordName) { continue }
                    ids.append((record["imageId"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            cursor = response.queryCursor
        } while cursor != nil
        return ids
    }

    // Import preflight: complete read-only image identity inventory.
    // Does not request imageAsset and fails closed on any partial query error.
    func fetchImageIdentitiesForImportCheck() async throws -> [(imageID: String, textileID: String, recordName: String)] {
        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        var cursor: CKQueryOperation.Cursor?
        var result: [(imageID: String, textileID: String, recordName: String)] = []
        repeat {
            let page: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let cursor {
                page = try await database.records(continuingMatchFrom: cursor, desiredKeys: ["imageId", "textileId"], resultsLimit: 100)
            } else {
                page = try await database.records(matching: query, inZoneWith: nil, desiredKeys: ["imageId", "textileId"], resultsLimit: 100)
            }
            for (_, recordResult) in page.matchResults {
                switch recordResult {
                case .failure(let error): throw error
                case .success(let record):
                    if Self.diagnosticRecordNames.contains(record.recordID.recordName) { continue }
                    result.append((
                        imageID: (record["imageId"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                        textileID: (record["textileId"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                        recordName: record.recordID.recordName
                    ))
                }
            }
            cursor = page.queryCursor
        } while cursor != nil
        return result
    }

    // Read-only inventory of ALL TextileImage records; CKAsset bytes are not downloaded.
    // Excludes the known diagnostic PoC record, consistent with normal image queries.
    func auditAllImageRecords(knownTextileIDs: Set<String>) async throws -> String {
        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        var cursor: CKQueryOperation.Cursor?
        var count = 0
        var missingImageID = 0
        var missingTextileID = 0
        var missingRecordName = 0
        var orphanCount = 0
        var primaryCount = 0
        var imageIDCounts: [String: Int] = [:]
        var primaryCounts: [String: Int] = [:]

        repeat {
            let response: (
                matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
                queryCursor: CKQueryOperation.Cursor?
            )
            if let cursor {
                response = try await database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: ["imageId", "textileId", "primary"],
                    resultsLimit: 100
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: ["imageId", "textileId", "primary"],
                    resultsLimit: 100
                )
            }
            for (_, result) in response.matchResults {
                switch result {
                case .failure(let error): throw error
                case .success(let record):
                    if Self.diagnosticRecordNames.contains(record.recordID.recordName) { continue }
                    count += 1
                    if record.recordID.recordName.isEmpty { missingRecordName += 1 }
                    let imageID = (record["imageId"] as? String ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let textileID = (record["textileId"] as? String ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if imageID.isEmpty {
                        missingImageID += 1
                    } else {
                        imageIDCounts[imageID, default: 0] += 1
                    }
                    if textileID.isEmpty {
                        missingTextileID += 1
                    } else if !knownTextileIDs.contains(textileID) {
                        orphanCount += 1
                    }
                    if (record["primary"] as? NSNumber)?.intValue == 1 {
                        primaryCount += 1
                        if !textileID.isEmpty { primaryCounts[textileID, default: 0] += 1 }
                    }
                }
            }
            cursor = response.queryCursor
        } while cursor != nil

        let duplicateIDs = imageIDCounts.values.filter { $0 > 1 }.count
        let multiplePrimaries = primaryCounts.values.filter { $0 > 1 }.count
        return "Bildeposter (alle, unntatt diagnostikk): \(count)\n" +
            "Primærbildeposter: \(primaryCount)\n" +
            "Dupliserte imageID-er: \(duplicateIDs)\n" +
            "Tekstiler med flere primærbilder: \(multiplePrimaries)\n" +
            "Bildeposter uten imageID: \(missingImageID)\n" +
            "Bildeposter uten textileId: \(missingTextileID)\n" +
            "Bildeposter uten forelder: \(orphanCount)\n" +
            "Bildeposter uten recordName: \(missingRecordName)"
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
