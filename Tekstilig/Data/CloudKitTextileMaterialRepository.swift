import CloudKit
import Foundation

@MainActor
final class CloudKitTextileMaterialRepository: TextileMaterialRepository {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"

    private static let recordType = "TextileMaterial"
    private let database: CKDatabase

    init(container: CKContainer? = nil) {
        let resolvedContainer = container ?? CKContainer(identifier: Self.containerIdentifier)
        database = resolvedContainer.privateCloudDatabase
    }

    func fetchMaterials(textileID: String) async throws -> [TextileMaterial] {
        let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("textileId")
        }

        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(format: "textileId == %@", normalizedTextileID)
        )

        let desiredKeys = ["materialId", "textileId", "material", "percent"]
        var materials: [TextileMaterial] = []
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
                    materials.append(try Self.material(from: record))
                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return materials.sorted {
            if $0.material != $1.material {
                return $0.material.localizedCaseInsensitiveCompare($1.material) == .orderedAscending
            }
            return ($0.percent ?? -1) > ($1.percent ?? -1)
        }
    }

    func save(_ material: TextileMaterial) async throws -> TextileMaterial {
        let normalizedTextileID = material.textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedMaterial = material.material.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("textileId")
        }
        guard !normalizedMaterial.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("material")
        }
        if let percent = material.percent, !(0...100).contains(percent) {
            throw CloudKitTextileMaterialRepositoryError.invalidPercent
        }

        let record: CKRecord
        if let cloudRecordName = material.cloudRecordName {
            record = try await database.record(for: CKRecord.ID(recordName: cloudRecordName))
            guard record.recordType == Self.recordType else {
                throw CloudKitTextileMaterialRepositoryError.unexpectedRecordType(record.recordType)
            }
        } else {
            record = CKRecord(recordType: Self.recordType)
        }

        record["materialId"] = material.materialID as CKRecordValue
        record["textileId"] = normalizedTextileID as CKRecordValue
        record["material"] = normalizedMaterial as CKRecordValue

        if let percent = material.percent {
            record["percent"] = NSNumber(value: percent)
        } else {
            record["percent"] = nil
        }

        let savedRecord = try await database.save(record)
        return try Self.material(from: savedRecord)
    }

    func delete(_ material: TextileMaterial) async throws {
        guard let cloudRecordName = material.cloudRecordName else {
            throw CloudKitTextileMaterialRepositoryError.missingCloudRecordName
        }
        _ = try await database.deleteRecord(withID: CKRecord.ID(recordName: cloudRecordName))
    }

    private static func material(from record: CKRecord) throws -> TextileMaterial {
        guard record.recordType == recordType else {
            throw CloudKitTextileMaterialRepositoryError.unexpectedRecordType(record.recordType)
        }
        guard let materialID = record["materialId"] as? String, !materialID.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("materialId")
        }
        guard let textileID = record["textileId"] as? String, !textileID.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("textileId")
        }
        guard let materialName = record["material"] as? String, !materialName.isEmpty else {
            throw CloudKitTextileMaterialRepositoryError.missingRequiredField("material")
        }

        return TextileMaterial(
            materialID: materialID,
            cloudRecordName: record.recordID.recordName,
            textileID: textileID,
            material: materialName,
            percent: (record["percent"] as? NSNumber)?.int64Value
        )
    }
}

private enum CloudKitTextileMaterialRepositoryError: LocalizedError {
    case unexpectedRecordType(String)
    case missingRequiredField(String)
    case invalidPercent
    case missingCloudRecordName

    var errorDescription: String? {
        switch self {
        case .unexpectedRecordType(let actual):
            return "Forventet CloudKit record type TextileMaterial, men fikk \(actual)."
        case .missingRequiredField(let field):
            return "En TextileMaterial-record mangler det påkrevde feltet \(field)."
        case .invalidPercent:
            return "Prosentandel må være mellom 0 og 100."
        case .missingCloudRecordName:
            return "Materialet er ikke lagret i CloudKit og kan derfor ikke slettes."
        }
    }
}
