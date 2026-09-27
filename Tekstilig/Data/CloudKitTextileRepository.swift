import CloudKit
import Foundation

@MainActor
final class CloudKitTextileRepository: TextileRepository {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"

    private static let recordType = "Textile"
    private static let diagnosticRecordNames: Set<String> = [
        "swiftui-poc-textile-v1"
    ]

    private let database: CKDatabase

    init(container: CKContainer? = nil) {
        let resolvedContainer = container ?? CKContainer(identifier: Self.containerIdentifier)
        database = resolvedContainer.privateCloudDatabase
    }

    func fetchTextiles() async throws -> [Textile] {
        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(value: true)
        )

        let desiredKeys = [
            "textileId",
            "name",
            "category",
            "createdAt",
            "updatedAt",
            "schemaVersion"
        ]

        var textiles: [Textile] = []
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
                    resultsLimit: 200
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: desiredKeys,
                    resultsLimit: 200
                )
            }

            for (_, result) in response.matchResults {
                switch result {
                case .success(let record):
                    guard !Self.diagnosticRecordNames.contains(record.recordID.recordName) else {
                        continue
                    }
                    textiles.append(try Self.textile(from: record))

                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return textiles.sorted {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func save(_ textile: Textile) async throws -> Textile {
        let record: CKRecord

        if let cloudRecordName = textile.cloudRecordName {
            record = try await database.record(
                for: CKRecord.ID(recordName: cloudRecordName)
            )

            guard record.recordType == Self.recordType else {
                throw CloudKitTextileRepositoryError.unexpectedRecordType(record.recordType)
            }
        } else {
            record = CKRecord(recordType: Self.recordType)
        }

        let now = Date()
        record["textileId"] = textile.textileID as CKRecordValue
        record["name"] = textile.name as CKRecordValue
        record["category"] = textile.category as CKRecordValue
        record["createdAt"] = textile.createdAt as CKRecordValue
        record["updatedAt"] = now as CKRecordValue
        record["schemaVersion"] = NSNumber(value: textile.schemaVersion)

        let savedRecord = try await database.save(record)
        return try Self.textile(from: savedRecord)
    }

    private static func textile(from record: CKRecord) throws -> Textile {
        guard record.recordType == recordType else {
            throw CloudKitTextileRepositoryError.unexpectedRecordType(record.recordType)
        }

        guard let textileID = record["textileId"] as? String,
              !textileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitTextileRepositoryError.missingRequiredField("textileId")
        }

        guard let name = record["name"] as? String,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitTextileRepositoryError.missingRequiredField("name")
        }

        let category = record["category"] as? String ?? ""
        let createdAt = (record["createdAt"] as? Date) ?? record.creationDate ?? Date()
        let updatedAt = (record["updatedAt"] as? Date) ?? record.modificationDate ?? createdAt
        let schemaVersion = (record["schemaVersion"] as? NSNumber)?.intValue ?? 1

        return Textile(
            textileID: textileID,
            cloudRecordName: record.recordID.recordName,
            name: name,
            category: category,
            createdAt: createdAt,
            updatedAt: updatedAt,
            schemaVersion: schemaVersion
        )
    }
}

private enum CloudKitTextileRepositoryError: LocalizedError {
    case unexpectedRecordType(String)
    case missingRequiredField(String)

    var errorDescription: String? {
        switch self {
        case .unexpectedRecordType(let actual):
            return "Forventet CloudKit record type Textile, men fikk \(actual)."
        case .missingRequiredField(let field):
            return "En Textile-record mangler det påkrevde feltet \(field)."
        }
    }
}
