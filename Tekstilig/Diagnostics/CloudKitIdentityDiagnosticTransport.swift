import CloudKit
import Foundation

// No instance is created or invoked by phase A's UI/tests. No save/delete capability.
@MainActor
final class CloudKitIdentityDiagnosticTransport: ImportIdentityReadTransport {
    typealias D = ImportIdentityReadDiagnostic
    private let container: CKContainer
    private let database: CKDatabase
    private let zoneID: CKRecordZone.ID
    private let expectedEnvironment: CloudKitEnvironmentVerification.Environment?
    private var environmentAccepted = false
    private var cursors: [String: (ImportIdentityDecisionModel.RecordType, CKQueryOperation.Cursor)] = [:]

    init(container: CKContainer, zoneID: CKRecordZone.ID, expectedEnvironment: CloudKitEnvironmentVerification.Environment?) {
        self.container = container
        self.database = container.privateCloudDatabase
        self.zoneID = zoneID
        self.expectedEnvironment = expectedEnvironment
    }

    enum ReadError: Error { case unverifiedEnvironment, unavailableAccount, missingContainer, invalidCursor }

    func context() async throws -> D.Context {
        environmentAccepted = false
        let context = try await CloudKitEnvironmentVerification.withVerifiedEnvironment(
            source: SystemCloudKitEnvironmentEvidenceSource(), expected: expectedEnvironment) { environment in
                guard let identifier = container.containerIdentifier else { throw ReadError.missingContainer }
                guard try await container.accountStatus() == .available else { throw ReadError.unavailableAccount }
                let userID = try await container.userRecordID()
                return D.Context(scope: .init(container: identifier, environment: environment.rawValue, account: userID.recordName,
                    database: database.databaseScope == .private ? "private" : "unsupported",
                    zone: zoneID.zoneName, zoneOwner: zoneID.ownerName), environmentSource: .signedApplicationEntitlement,
                    expectedEnvironment: expectedEnvironment)
            }
        environmentAccepted = true
        return context
    }

    func page(type: ImportIdentityDecisionModel.RecordType, after cursor: String?) async throws -> D.Page {
        try Task.checkCancellation()
        guard environmentAccepted else { throw ReadError.unverifiedEnvironment }
        let response: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?)
        if let cursor {
            guard let stored = cursors.removeValue(forKey: cursor), stored.0 == type else { throw ReadError.invalidCursor }
            response = try await database.records(continuingMatchFrom: stored.1, desiredKeys: D.desiredKeys(type), resultsLimit: 200)
        } else {
            response = try await database.records(matching: CKQuery(recordType: type.rawValue, predicate: NSPredicate(value: true)),
                inZoneWith: zoneID, desiredKeys: D.desiredKeys(type), resultsLimit: 200)
        }
        var values: [D.Observation] = []
        var errors: [String] = []
        for (id, result) in response.matchResults {
            switch result {
            case .success(let record): values.append(Self.observation(record, requestedType: type))
            case .failure(let error): errors.append("\(id.zoneID.zoneName)/\(id.zoneID.ownerName)/\(id.recordName): \(error)")
            }
        }
        let token = response.queryCursor.map { cursor -> String in
            let token = UUID().uuidString
            cursors[token] = (type, cursor)
            return token
        }
        return D.Page(observations: values, recordErrors: errors, nextCursor: token)
    }

    static func observation(_ record: CKRecord, requestedType: ImportIdentityDecisionModel.RecordType) -> D.Observation {
        func raw(_ key: String) -> D.RawField {
            guard let value = record[key] else { return .missing }
            if let string = value as? String { return .string(string) }
            return .nonString(type: String(reflecting: Swift.type(of: value)), description: String(reflecting: value))
        }
        let id = raw(D.idField(requestedType))
        return D.Observation(recordType: record.recordType, logicalID: id,
            owner: requestedType == .textile ? id : raw("textileId"), recordName: record.recordID.recordName,
            zone: record.recordID.zoneID.zoneName, zoneOwner: record.recordID.zoneID.ownerName,
            changeTag: record.recordChangeTag)
    }
}
