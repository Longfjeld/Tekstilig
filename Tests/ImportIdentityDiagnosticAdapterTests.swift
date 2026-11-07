import Darwin

@main
struct ImportIdentityDiagnosticAdapterTests {
    typealias A = ImportIdentityDiagnosticAdapter
    typealias M = ImportIdentityDecisionModel
    static let scope = M.Scope(container: "synthetic", environment: "test", account: "fixture",
        database: "private", zone: "default", zoneOwner: "fixture")
    static let hash = String(repeating: "a", count: 64)
    static let journalID = "00000000-0000-0000-0000-000000000001"
    static let family: [A.IdentityRecord] = M.RecordType.allCases.map {
        A.IdentityRecord(type: $0.rawValue, logicalID: $0 == .textile ? "T-1" : "ID-\($0.rawValue)", owner: "T-1")
    }
    static func key(_ record: A.IdentityRecord) -> M.Key {
        M.Key(type: M.RecordType(rawValue: record.type)!, logicalID: record.logicalID)
    }
    static func identity(_ record: A.IdentityRecord) -> M.Identity { M.Identity(key: key(record), owner: record.owner) }
    static func record(_ version: A.VersionRecord) -> M.InventoryRecord {
        M.InventoryRecord(type: M.RecordType(rawValue: version.type)!,
            address: M.Address(scope: version.scope!, recordName: version.recordName))
    }
    static func fixture(existing: Bool = false) -> A.Snapshot {
        let live = existing ? family.enumerated().map { index, value in
            A.IdentityRecord(type: value.type, logicalID: value.logicalID, owner: value.owner,
                recordName: "random-existing-\(index)", scope: scope)
        } : []
        let versions = live.map { A.VersionRecord(type: $0.type, recordName: $0.recordName, changeTag: "tag-1", scope: scope) }
        return A.Snapshot(scope: scope, backup: family, observed: live, current: versions,
            baseline: A.Baseline(schemaVersion: 1, journalID: journalID, zipSHA256: hash, entries: versions),
            journal: journal(operations: existing ? [] : family.map { "\($0.type):\($0.logicalID)" }),
            selectedZIPHash: hash, coverage: .init(verifiedIdentityTypes: Set(M.RecordType.allCases),
                completeNameInventory: true, completeVersions: true, readErrors: []), rawIdentitiesVerified: true)
    }
    static func journal(operations: [String], id: String = journalID, zip: String = hash,
                        completed: Int = 0, schema: Int = 2) -> A.Journal {
        A.Journal(schemaVersion: schema, journalID: id, state: "planned-read-only", operationIDs: operations,
            completedOperationCount: completed, zipSHA256: zip)
    }
    static func baseline(_ entries: [A.VersionRecord], id: String = journalID, zip: String = hash, schema: Int = 1) -> A.Baseline {
        A.Baseline(schemaVersion: schema, journalID: id, zipSHA256: zip, entries: entries)
    }
    // Full expected reports: exact keys, row count, variants, reasons and addresses.
    static func stopped(_ source: A.Snapshot, _ stops: [M.Stop], invalid: Bool = true) -> Bool {
        let report = M.evaluate(A.adapt(source).input)
        let ordered = Array(Set(stops)).sorted()
        let keys = Set(source.backup.compactMap { value -> M.Key? in
            M.RecordType(rawValue: value.type).map { M.Key(type: $0, logicalID: value.logicalID) }
        }).sorted()
        let expected = M.Report(rows: keys.map { M.Row(key: $0,
            decision: invalid ? .stopInvalidBasis(ordered) : .stopConflict(ordered)) }, globalStops: ordered)
        return report == expected && report.hasStops && !report.permitsCloudKitWriting
    }
    static func candidates(_ source: A.Snapshot) -> Bool {
        let report = M.evaluate(A.adapt(source).input)
        let expected = M.Report(rows: family.sorted { key($0) < key($1) }.map { value in
            let k = key(value)
            return M.Row(key: k, decision: .candidateForCreation(M.Candidate(identity: identity(value),
                address: M.Address(scope: scope, recordName: M.candidateName(for: k)),
                strategyVersion: "diagnostic-hex-v1-provisional",
                parent: k.type == .textile ? nil : M.Key(type: .textile, logicalID: "T-1"))))
        }, globalStops: [])
        return report == expected && !report.hasStops && !report.permitsCloudKitWriting
    }

    static func main() {
        var passed = 0
        func check(_ name: String, _ body: () -> Bool) {
            guard body() else { print("FAIL \(name)"); exit(1) }
            passed += 1
            print("PASS \(name)")
        }
        check("01 five new candidates and parent dependencies") { candidates(fixture()) }
        check("02 five exact existing identities and record names") {
            let source = fixture(existing: true)
            let adapted = A.adapt(source)
            let expected = M.Report(rows: source.observed.sorted { key($0) < key($1) }.map {
                M.Row(key: key($0), decision: .reuseExisting(M.Observed(identity: identity($0),
                    address: M.Address(scope: scope, recordName: $0.recordName))))
            }, globalStops: [])
            return adapted.issues.isEmpty && M.evaluate(adapted.input) == expected && !expected.permitsCloudKitWriting
        }
        check("03 lossless structured fields including duplicate arrays") {
            var source = fixture(existing: true)
            source.observed.append(source.observed[1])
            let input = A.adapt(source).input
            return input.scope == scope && input.backup == source.backup.map(identity) &&
                input.observed == source.observed.map { M.Observed(identity: identity($0), address: .init(scope: scope, recordName: $0.recordName)) } &&
                input.current == source.current!.map { M.Version(record: record($0), changeTag: $0.changeTag) } &&
                input.baseline == input.current && input.inventory == source.current!.map(record) &&
                input.binding == M.Binding(selectedZIPHash: hash, journalZIPHash: hash, expectedJournalID: journalID,
                    journalID: journalID, baselineJournalID: journalID, baselineZIPHash: hash, operations: []) &&
                input.coverage == source.coverage
        }
        check("04 missing context stops, never inferred") {
            var source = fixture(); source.scope = nil
            return stopped(source, [.init(.invalidScope), .init(.incompleteCoverage)])
        }
        check("05 unverified raw identities stop") {
            var source = fixture(); source.rawIdentitiesVerified = false
            return stopped(source, [.init(.incompleteCoverage)])
        }
        check("06 all three exact filtered PoC identities unresolved") {
            var source = fixture()
            let values = [("Textile", "swiftui-poc-textile-v1"), ("Piece", "swiftui-poc-piece-v1"), ("TextileImage", "swiftui-poc-textile-image-v1")]
                .map { A.VersionRecord(type: $0.0, recordName: $0.1, changeTag: "1", scope: scope) }
            source.current = values; source.baseline = baseline(values)
            return stopped(source, values.map { M.Stop(.unresolvedFilteredIdentity, address: record($0).address) }) &&
                A.adapt(source).input.inventory.count == 3
        }
        check("07 unexplained inventory is not silently dropped") {
            var source = fixture()
            let value = A.VersionRecord(type: "TextileColor", recordName: "unexplained", changeTag: "1", scope: scope)
            source.current = [value]; source.baseline = baseline([value])
            return stopped(source, [.init(.unexplainedInventoryRecord, address: record(value).address)])
        }
        check("08 mismatched selected ZIP hash") {
            var source = fixture(); source.selectedZIPHash = String(repeating: "b", count: 64)
            return stopped(source, [.init(.invalidBinding)])
        }
        check("09 mismatched journal ID independently") {
            var source = fixture(); source.journal = journal(operations: source.journal!.operationIDs,
                id: "00000000-0000-0000-0000-000000000002")
            return stopped(source, [.init(.invalidBinding)])
        }
        check("10 missing journal and baseline") {
            var source = fixture(); source.journal = nil; source.baseline = nil
            return stopped(source, [.init(.missingBaseline), .init(.invalidBinding)])
        }
        check("11 duplicate backup logical ID preserved") {
            var source = fixture(); source.backup.append(family[1])
            return stopped(source, [.init(.duplicateBackupID, key: key(family[1]))], invalid: false)
        }
        check("12 duplicate observed ID with distinct names preserved") {
            var source = fixture(existing: true)
            var duplicate = source.observed[1]; duplicate.recordName = "another-name"
            source.observed.append(duplicate)
            let value = A.VersionRecord(type: duplicate.type, recordName: duplicate.recordName, changeTag: "1", scope: scope)
            source.current!.append(value); source.baseline = baseline(source.current!)
            return stopped(source, [.init(.duplicateObservedID, key: key(duplicate))], invalid: false)
        }
        check("13 partial read and coverage remain stops") {
            var source = fixture()
            source.coverage = .init(verifiedIdentityTypes: [.textile], completeNameInventory: false,
                completeVersions: false, readErrors: ["synthetic page failure"])
            return stopped(source, [.init(.incompleteCoverage)]) &&
                A.adapt(source).input.coverage.readErrors == ["synthetic page failure"]
        }
        check("14 missing current versions") {
            var source = fixture(); source.current = nil
            return stopped(source, [.init(.missingBaseline)])
        }
        check("15 changed baseline tag") {
            var source = fixture(existing: true)
            var values = source.current!
            values[0] = A.VersionRecord(type: values[0].type, recordName: values[0].recordName, changeTag: "different", scope: scope)
            source.baseline = baseline(values)
            return stopped(source, [.init(.baselineChanged)])
        }
        check("16 diagnostic completion count never invents operation outcomes") {
            var source = fixture(); source.journal = journal(operations: source.journal!.operationIDs, completed: 1)
            return stopped(source, [.init(.incompleteCoverage), .init(.invalidBinding)]) && A.adapt(source).input.binding == nil
        }
        check("17 invalid schemas stop without repair") {
            var source = fixture(); source.baseline = baseline([], schema: 7)
            source.journal = journal(operations: source.journal!.operationIDs, schema: 7)
            return stopped(source, [.init(.incompleteCoverage), .init(.invalidBinding)])
        }
        check("18 malformed operation encoding is explicit") {
            var source = fixture(); source.journal = journal(operations: source.journal!.operationIDs + ["malformed"])
            return stopped(source, [.init(.incompleteCoverage)]) && A.adapt(source).issues.contains("Ugyldig journaloperasjon: \"malformed\"")
        }
        check("19 raw spaces retained, not normalized") {
            var source = fixture(); let value = family[1]
            source.backup[1] = A.IdentityRecord(type: value.type, logicalID: value.logicalID, owner: " T-1 ")
            let input = A.adapt(source).input
            return input.backup[1].owner == " T-1 " && stopped(source,
                [.init(.invalidIdentity, key: key(value)), .init(.invalidOperationPlan)])
        }
        check("20 unknown type cannot disappear without a stop") {
            var source = fixture(); source.observed = [A.IdentityRecord(type: "Unknown", logicalID: "X", owner: "T-1")]
            return stopped(source, [.init(.incompleteCoverage)]) && !A.adapt(source).issues.isEmpty
        }
        check("21 deterministic repeat and reordered input, immutable source") {
            let source = fixture(existing: true); let before = source
            var reversed = source; reversed.backup.reverse(); reversed.observed.reverse(); reversed.current!.reverse()
            reversed.baseline = baseline(reversed.current!)
            return source == before && A.render(source) == A.render(reversed) &&
                M.evaluate(A.adapt(source).input) == M.evaluate(A.adapt(reversed).input)
        }
        check("22 empty report cannot satisfy positive oracle") {
            var source = fixture(); source.backup = []
            return !candidates(source)
        }
        check("23 report explicitly denies writing and production approval") {
            let text = A.render(fixture())
            return text.contains("CloudKit-skriving: false") &&
                text.componentsCount("candidateForCreation") == 5 && text.componentsCount("approvedForProduction: false") == 5
        }
        print("\(passed) PASS, 0 FAIL")
    }
}

private extension String {
    func componentsCount(_ needle: String) -> Int {
        let bytes = Array(utf8), target = Array(needle.utf8)
        guard !target.isEmpty, bytes.count >= target.count else { return 0 }
        return (0...(bytes.count - target.count)).filter {
            Array(bytes[$0..<($0 + target.count)]) == target
        }.count
    }
}
