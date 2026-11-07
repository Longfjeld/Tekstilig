import CloudKit
import Foundation
#if os(macOS)
import Security
#endif

// No instance is created or invoked by phase A's UI/tests. No save/delete capability.
@MainActor
final class CloudKitIdentityDiagnosticTransport: ImportIdentityReadTransport {
    typealias D = ImportIdentityReadDiagnostic
    private let container: CKContainer
    private let database: CKDatabase
    private let zoneID: CKRecordZone.ID
    private var cursors: [String: (ImportIdentityDecisionModel.RecordType, CKQueryOperation.Cursor)] = [:]

    init(container: CKContainer, zoneID: CKRecordZone.ID) {
        self.container = container
        self.database = container.privateCloudDatabase
        self.zoneID = zoneID
    }

    enum ReadError: Error { case unverifiedEnvironment, unavailableAccount, missingContainer, invalidCursor }

    func context() async throws -> D.Context {
        // DEBUG and APS entitlements are deliberately not environment evidence.
        guard let environment = Self.signedEnvironment() else { throw ReadError.unverifiedEnvironment }
        guard let identifier = container.containerIdentifier else { throw ReadError.missingContainer }
        guard try await container.accountStatus() == .available else { throw ReadError.unavailableAccount }
        let userID = try await container.userRecordID()
        return D.Context(scope: .init(container: identifier, environment: environment, account: userID.recordName,
            database: database.databaseScope == .private ? "private" : "unsupported",
            zone: zoneID.zoneName, zoneOwner: zoneID.ownerName), environmentSource: .signedApplicationEntitlement)
    }

    private static func signedEnvironment() -> String? {
        #if os(macOS)
        var code: SecCode?
        guard SecCodeCopySelf(SecCSFlags(rawValue: 0), &code) == errSecSuccess, let code else { return nil }
        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(code, SecCSFlags(rawValue: 0), &staticCode) == errSecSuccess, let staticCode else { return nil }
        var information: CFDictionary?
        guard SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &information) == errSecSuccess,
              let info = information as? [String: Any],
              let entitlements = info[kSecCodeInfoEntitlementsDict as String] as? [String: Any],
              let value = entitlements["com.apple.developer.icloud-container-environment"] as? String,
              ["Development", "Production"].contains(value) else { return nil }
        return value
        #else
        // No supported iOS entitlement reader is established in this phase. Fail closed.
        return nil
        #endif
    }

    func page(type: ImportIdentityDecisionModel.RecordType, after cursor: String?) async throws -> D.Page {
        try Task.checkCancellation()
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
