// Test 239: value-only classification. No IO, framework imports or write authority.
nonisolated enum ImportIdentityDecisionModel {
    enum RecordType: String, CaseIterable, Hashable {
        case textile = "Textile", piece = "Piece", material = "TextileMaterial"
        case color = "TextileColor", image = "TextileImage"
    }

    struct Key: Hashable, Comparable {
        let type: RecordType
        let logicalID: String
        static func < (lhs: Self, rhs: Self) -> Bool {
            (lhs.type.rawValue, lhs.logicalID) < (rhs.type.rawValue, rhs.logicalID)
        }
    }

    // Supplied context, never discovered from an account, filesystem or server.
    struct Scope: Hashable {
        let container: String
        let environment: String
        let account: String
        let database: String
        let zone: String
        let zoneOwner: String
        fileprivate var fields: [String] { [container, environment, account, database, zone, zoneOwner] }
    }

    struct Address: Hashable {
        let scope: Scope
        let recordName: String
    }

    struct Identity: Hashable {
        let key: Key
        let owner: String
    }

    struct Observed: Hashable {
        let identity: Identity
        let address: Address
    }

    // Includes records omitted from user-facing identity reads, including PoC.
    struct InventoryRecord: Hashable {
        let type: RecordType
        let address: Address
    }

    struct Version: Hashable {
        let record: InventoryRecord
        let changeTag: String
    }

    enum OperationState: Hashable { case planned, completed, unknownOutcome }
    struct Operation: Hashable {
        let key: Key
        let state: OperationState
    }

    // Synthetic binding evidence, not an on-disk journal format or executor.
    struct Binding: Equatable {
        let selectedZIPHash: String
        let journalZIPHash: String
        let expectedJournalID: String
        let journalID: String
        let baselineJournalID: String
        let baselineZIPHash: String
        let operations: [Operation]
    }

    struct Coverage: Equatable {
        let verifiedIdentityTypes: Set<RecordType>
        let completeNameInventory: Bool
        let completeVersions: Bool
        let readErrors: [String]
    }

    struct Input: Equatable {
        let scope: Scope
        let backup: [Identity]
        let observed: [Observed]
        let inventory: [InventoryRecord]
        let baseline: [Version]?
        let current: [Version]?
        let binding: Binding?
        let coverage: Coverage
    }

    enum StopCode: String, Hashable {
        case invalidScope, invalidIdentity, invalidRecordName, incompleteCoverage
        case inconsistentInventory, unexplainedInventoryRecord, unresolvedFilteredIdentity
        case missingBaseline, missingVersionTag, invalidVersions, baselineChanged
        case invalidBinding, invalidOperationPlan, partialImport, unknownServerOutcome
        case duplicateBackupID, duplicateObservedID, duplicateRecordAddress
        case ownerConflict, missingParent, ambiguousParent, parentStopped
        case existingTextileCompletion, candidateNameCollision, candidateNameTooLong
    }

    struct Stop: Hashable, Comparable {
        let code: StopCode
        let key: Key?
        let address: Address?
        init(_ code: StopCode, key: Key? = nil, address: Address? = nil) {
            self.code = code; self.key = key; self.address = address
        }
        private var fields: [String] {
            [code.rawValue, key?.type.rawValue ?? "", key?.logicalID ?? ""] +
            (address?.scope.fields ?? []) + [address?.recordName ?? ""]
        }
        static func < (lhs: Self, rhs: Self) -> Bool { lhs.fields.lexicographicallyPrecedes(rhs.fields) }
    }

    struct Candidate: Equatable {
        let identity: Identity
        let address: Address
        let strategyVersion: String
        let parent: Key?
        let approvedForProduction = false
    }

    enum Decision: Equatable {
        case reuseExisting(Observed)
        case candidateForCreation(Candidate)
        case stopConflict([Stop])
        case stopInvalidBasis([Stop])
        var stops: [Stop] {
            switch self {
            case .stopConflict(let stops), .stopInvalidBasis(let stops): return stops
            default: return []
            }
        }
    }

    struct Row: Equatable {
        let key: Key
        let decision: Decision
    }

    struct Report: Equatable {
        let rows: [Row]
        let globalStops: [Stop]
        var hasStops: Bool { !globalStops.isEmpty || rows.contains { !$0.decision.stops.isEmpty } }
        // A successful classification never authorizes creation or content changes.
        var permitsCloudKitWriting: Bool { false }
    }

    static let strategyVersion = "diagnostic-hex-v1-provisional"

    static func candidateName(for key: Key) -> String {
        // Same formula as test 238, kept independent of its validated renderer.
        let hex = "\(key.type.rawValue):\(key.logicalID)".utf8.map { byte in
            let value = String(byte, radix: 16)
            return value.count == 1 ? "0" + value : value
        }.joined()
        return "tekstilig-import-v1-" + hex
    }

    // Shared collision rule: no type or PoC filtering. Can be tested with any
    // synthetic proposed address without changing the candidate-name algorithm.
    static func nameConflicts(proposed: Address, inventory: [InventoryRecord]) -> Bool {
        inventory.contains { $0.address == proposed }
    }

    private static func isDocumentedPoCFilter(_ record: InventoryRecord) -> Bool {
        switch (record.type, record.address.recordName) {
        case (.textile, "swiftui-poc-textile-v1"), (.piece, "swiftui-poc-piece-v1"),
             (.image, "swiftui-poc-textile-image-v1"): return true
        default: return false
        }
    }

    static func evaluate(_ input: Input) -> Report {
        let backup = Dictionary(grouping: input.backup, by: \.key)
        let observed = Dictionary(grouping: input.observed, by: { $0.identity.key })
        let keys = backup.keys.sorted()
        var invalid: [Stop] = []
        var conflicts: [Stop] = []

        if !input.scope.fields.allSatisfy(validToken) { invalid.append(Stop(.invalidScope)) }
        if input.coverage.verifiedIdentityTypes != Set(RecordType.allCases) ||
            !input.coverage.completeNameInventory || !input.coverage.completeVersions ||
            !input.coverage.readErrors.isEmpty {
            invalid.append(Stop(.incompleteCoverage))
        }
        for identity in input.backup + input.observed.map(\.identity) {
            if !validToken(identity.key.logicalID) || !validToken(identity.owner) ||
                (identity.key.type == .textile && identity.owner != identity.key.logicalID) {
                invalid.append(Stop(.invalidIdentity, key: identity.key))
            }
        }
        for record in input.inventory {
            if record.address.scope != input.scope { invalid.append(Stop(.invalidScope, address: record.address)) }
            if !validRecordName(record.address.recordName) {
                invalid.append(Stop(.invalidRecordName, address: record.address))
            }
        }
        for (key, values) in backup where values.count > 1 { conflicts.append(Stop(.duplicateBackupID, key: key)) }
        for (key, values) in observed where values.count > 1 { conflicts.append(Stop(.duplicateObservedID, key: key)) }
        for (address, values) in Dictionary(grouping: input.inventory, by: \.address) where values.count > 1 {
            conflicts.append(Stop(.duplicateRecordAddress, address: address))
        }
        for (_, values) in Dictionary(grouping: input.observed, by: \.address) where values.count > 1 {
            conflicts.append(Stop(.duplicateRecordAddress, address: values[0].address))
        }
        let inventory = Set(input.inventory)
        for item in input.observed where !inventory.contains(InventoryRecord(type: item.identity.key.type, address: item.address)) {
            invalid.append(Stop(.inconsistentInventory, key: item.identity.key, address: item.address))
        }
        let observedRecords = Set(input.observed.map {
            InventoryRecord(type: $0.identity.key.type, address: $0.address)
        })
        for record in inventory where !observedRecords.contains(record) {
            // A known filter explains omission, not logical identity or ownership.
            // Its name stays occupied; missing identity evidence still stops us.
            invalid.append(Stop(isDocumentedPoCFilter(record) ? .unresolvedFilteredIdentity :
                .unexplainedInventoryRecord, address: record.address))
        }
        if let baseline = input.baseline, let current = input.current {
            for version in baseline + current {
                if !validToken(version.changeTag) { invalid.append(Stop(.missingVersionTag, address: version.record.address)) }
                if version.record.address.scope != input.scope || !validRecordName(version.record.address.recordName) {
                    invalid.append(Stop(.invalidVersions, address: version.record.address))
                }
            }
            for versions in [baseline, current] {
                if Set(versions.map { $0.record.address }).count != versions.count { invalid.append(Stop(.invalidVersions)) }
            }
            if Set(current.map(\.record)) != inventory { invalid.append(Stop(.inconsistentInventory)) }
            if Set(baseline) != Set(current) { invalid.append(Stop(.baselineChanged)) }
        } else {
            invalid.append(Stop(.missingBaseline))
        }

        // Existing families are observation-only: no completion of their children.
        let newParents = Set(input.backup.filter {
            $0.key.type == .textile && observed[$0.key] == nil
        }.map { $0.key.logicalID })
        let plannedKeys = Set(input.backup.filter { newParents.contains($0.owner) }.map(\.key))
        if let binding = input.binding {
            if !validHash(binding.selectedZIPHash) || binding.selectedZIPHash != binding.journalZIPHash ||
                binding.selectedZIPHash != binding.baselineZIPHash || !validJournalID(binding.journalID) ||
                binding.journalID != binding.expectedJournalID || binding.journalID != binding.baselineJournalID {
                invalid.append(Stop(.invalidBinding))
            }
            if Set(binding.operations.map(\.key)) != plannedKeys ||
                Set(binding.operations.map(\.key)).count != binding.operations.count {
                invalid.append(Stop(.invalidOperationPlan))
            }
            for operation in binding.operations {
                switch operation.state {
                case .planned: break
                case .completed: invalid.append(Stop(.partialImport, key: operation.key))
                case .unknownOutcome: invalid.append(Stop(.unknownServerOutcome, key: operation.key))
                }
            }
        } else { invalid.append(Stop(.invalidBinding)) }

        let invalidStops = ordered(invalid)
        let conflictStops = ordered(conflicts)
        if !invalidStops.isEmpty || !conflictStops.isEmpty {
            return Report(rows: keys.map { key in
                Row(key: key, decision: !invalidStops.isEmpty ? .stopInvalidBasis(invalidStops) : .stopConflict(conflictStops))
            }, globalStops: ordered(invalidStops + conflictStops))
        }

        func classify(_ identity: Identity) -> Decision {
            let matches = observed[identity.key] ?? []
            if let actual = matches.first, actual.identity.owner != identity.owner {
                return .stopConflict([Stop(.ownerConflict, key: identity.key, address: actual.address)])
            }
            var parentKey: Key?
            if identity.key.type != .textile {
                let parent = Key(type: .textile, logicalID: identity.owner)
                parentKey = parent
                let liveParents = observed[parent] ?? []
                let backupParents = backup[parent] ?? []
                if liveParents.count > 1 || backupParents.count > 1 {
                    return .stopConflict([Stop(.ambiguousParent, key: parent)])
                }
                if liveParents.isEmpty && (backupParents.isEmpty || !matches.isEmpty) {
                    return .stopConflict([Stop(.missingParent, key: parent)])
                }
                if let wantedParent = backupParents.first, !classify(wantedParent).stops.isEmpty {
                    return .stopConflict([Stop(.parentStopped, key: parent)])
                }
                if matches.isEmpty && !liveParents.isEmpty {
                    return .stopConflict([Stop(.existingTextileCompletion, key: identity.key)])
                }
            }
            if let actual = matches.first { return .reuseExisting(actual) }
            let name = candidateName(for: identity.key)
            if name.utf8.count > 255 { return .stopInvalidBasis([Stop(.candidateNameTooLong, key: identity.key)]) }
            let address = Address(scope: input.scope, recordName: name)
            if nameConflicts(proposed: address, inventory: input.inventory) {
                return .stopConflict([Stop(.candidateNameCollision, key: identity.key, address: address)])
            }
            return .candidateForCreation(Candidate(identity: identity, address: address,
                strategyVersion: strategyVersion, parent: parentKey))
        }
        return Report(rows: keys.compactMap { key in
            backup[key]?.first.map { Row(key: key, decision: classify($0)) }
        }, globalStops: [])
    }

    private static func ordered(_ stops: [Stop]) -> [Stop] { Set(stops).sorted() }
    private static func validToken(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy { $0 >= 33 && $0 <= 126 }
    }
    private static func validRecordName(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.count <= 255 && value.utf8.allSatisfy { $0 >= 32 && $0 <= 126 }
    }
    private static func validHash(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }
    private static func validJournalID(_ value: String) -> Bool {
        let bytes = Array(value.utf8)
        return bytes.count == 36 && bytes.enumerated().allSatisfy { index, byte in
            if [8, 13, 18, 23].contains(index) { return byte == 45 }
            return (48...57).contains(byte) || (65...70).contains(byte) || (97...102).contains(byte)
        }
    }
}
