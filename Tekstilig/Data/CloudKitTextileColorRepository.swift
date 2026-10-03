import CloudKit
import Foundation

@MainActor
final class CloudKitTextileColorRepository: TextileColorRepository {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"

    private static let recordType = "TextileColor"
    private let database: CKDatabase

    init(container: CKContainer? = nil) {
        let resolvedContainer = container ?? CKContainer(identifier: Self.containerIdentifier)
        database = resolvedContainer.privateCloudDatabase
    }

    func fetchColors(textileID: String) async throws -> [TextileColor] {
        let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("textileId")
        }

        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(format: "textileId == %@", normalizedTextileID)
        )

        let desiredKeys = ["colorId", "textileId", "group", "name", "hex"]
        var colors: [TextileColor] = []
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
                    colors.append(try Self.color(from: record))
                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return colors.sorted {
            if $0.group != $1.group {
                return $0.group.localizedCaseInsensitiveCompare($1.group) == .orderedAscending
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func fetchAllColors() async throws -> [TextileColor] {
        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        let desiredKeys = ["colorId", "textileId", "group", "name", "hex"]
        var colors: [TextileColor] = []
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
                    colors.append(try Self.color(from: record))
                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return colors.sorted {
            if $0.textileID != $1.textileID {
                return $0.textileID < $1.textileID
            }
            if $0.group != $1.group {
                return $0.group.localizedCaseInsensitiveCompare($1.group) == .orderedAscending
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func save(_ color: TextileColor) async throws -> TextileColor {
        let normalizedTextileID = color.textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedGroup = color.group.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedName = color.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedHex = Self.normalizeHex(color.hex)

        guard !normalizedTextileID.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("textileId")
        }
        guard !normalizedGroup.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("group")
        }
        if !normalizedHex.isEmpty && !Self.isValidHex(normalizedHex) {
            throw CloudKitTextileColorRepositoryError.invalidHex
        }

        let record: CKRecord
        if let cloudRecordName = color.cloudRecordName {
            record = try await database.record(for: CKRecord.ID(recordName: cloudRecordName))
            guard record.recordType == Self.recordType else {
                throw CloudKitTextileColorRepositoryError.unexpectedRecordType(record.recordType)
            }
        } else {
            record = CKRecord(recordType: Self.recordType)
        }

        record["colorId"] = color.colorID as CKRecordValue
        record["textileId"] = normalizedTextileID as CKRecordValue
        record["group"] = normalizedGroup as CKRecordValue
        record["name"] = normalizedName as CKRecordValue
        record["hex"] = normalizedHex as CKRecordValue

        let savedRecord = try await database.save(record)
        return try Self.color(from: savedRecord)
    }

    func delete(_ color: TextileColor) async throws {
        guard let cloudRecordName = color.cloudRecordName else {
            throw CloudKitTextileColorRepositoryError.missingCloudRecordName
        }
        _ = try await database.deleteRecord(withID: CKRecord.ID(recordName: cloudRecordName))
    }

    private static func color(from record: CKRecord) throws -> TextileColor {
        guard record.recordType == recordType else {
            throw CloudKitTextileColorRepositoryError.unexpectedRecordType(record.recordType)
        }
        guard let colorID = record["colorId"] as? String, !colorID.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("colorId")
        }
        guard let textileID = record["textileId"] as? String, !textileID.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("textileId")
        }
        guard let group = record["group"] as? String, !group.isEmpty else {
            throw CloudKitTextileColorRepositoryError.missingRequiredField("group")
        }

        return TextileColor(
            colorID: colorID,
            cloudRecordName: record.recordID.recordName,
            textileID: textileID,
            group: group,
            name: record["name"] as? String ?? "",
            hex: record["hex"] as? String ?? ""
        )
    }

    private static func normalizeHex(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return "" }
        return trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
    }

    private static func isValidHex(_ value: String) -> Bool {
        guard value.count == 7, value.first == "#" else { return false }
        return value.dropFirst().allSatisfy { $0.isHexDigit }
    }
}

private enum CloudKitTextileColorRepositoryError: LocalizedError {
    case unexpectedRecordType(String)
    case missingRequiredField(String)
    case invalidHex
    case missingCloudRecordName

    var errorDescription: String? {
        switch self {
        case .unexpectedRecordType(let actual):
            return "Forventet CloudKit record type TextileColor, men fikk \(actual)."
        case .missingRequiredField(let field):
            return "En TextileColor-record mangler det påkrevde feltet \(field)."
        case .invalidHex:
            return "Hex-farge må være tom eller ha formatet #RRGGBB."
        case .missingCloudRecordName:
            return "Fargen er ikke lagret i CloudKit og kan derfor ikke slettes."
        }
    }
}
