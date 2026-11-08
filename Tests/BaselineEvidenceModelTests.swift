import Darwin

@main
struct BaselineEvidenceModelTests {
    typealias M = BaselineEvidenceModel
    static let id = M.Raw.string("3EC77AF2-223E-4556-AAFB-98376557CE47")
    static let digest = M.Raw.string(String(repeating: "a", count: 64))
    static let otherDigest = M.Raw.string(String(repeating: "b", count: 64))
    static let context = M.Context(container: .string("container"), environment: .string("Development"),
        account: .string("account"), database: .string("private"), zone: .string("zone"), zoneOwner: .string("owner"))
    static let claim = M.HistoricalClaim(context: context, evidenceSource: .string("synthetic-historical-document"))
    static let types = ["Textile", "Piece", "TextileMaterial", "TextileColor", "TextileImage"]
    static var records: [M.Record] {
        types.map { .init(recordType: .string($0), recordName: .string("random-" + $0), changeTag: .string("tag-" + $0)) }
    }
    static func baseline(_ claims: [M.HistoricalClaim] = [claim], _ entries: [M.Record] = records,
                         _ journalID: M.Raw = id, _ hash: M.Raw = digest) -> M.Baseline {
        .init(journalID: journalID, zipSHA256: hash, records: entries, historicalClaims: claims)
    }
    static func input(_ baselines: [M.Baseline] = [baseline()],
                      _ journals: [M.Journal] = [.init(journalID: id, zipSHA256: digest)],
                      _ hash: M.Raw = digest, _ current: [M.Context] = []) -> M.Input {
        .init(selectedZipSHA256: hash, journals: journals, baselines: baselines, currentContexts: current)
    }
    static func expect(_ source: M.Input, _ binding: M.Status, _ observations: M.Status, _ history: M.Status,
                       _ issues: [M.Issue]) -> Bool {
        let report = M.evaluate(source)
        return report.input == source && report.binding == binding && report.observations == observations &&
            report.historicalContext == history && report.issues == issues.sorted { $0.rawValue < $1.rawValue } &&
            report.hasStop == !issues.isEmpty && !report.permitsImport && !report.permitsCloudKitWriting &&
            report.recordGroups == source.baselines.map { $0.records.sorted { $0.order.lexicographicallyPrecedes($1.order) } }
    }
    static func main() {
        var count = 0
        func check(_ name: String, _ test: () -> Bool) {
            guard test() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        check("01 complete synthetic evidence: three separate documented assessments, no authority") {
            expect(input(), .documented, .documented, .documented, []) && M.evaluate(input()).recordGroups[0].count == 5
        }
        check("02 existing v1 shape retains binding and versions but historical context unresolved") {
            expect(input([baseline([])]), .documented, .documented, .unresolved, [.missingHistoricalContext])
        }
        check("03 current context never fills historical gap") {
            let source = input([baseline([])], [.init(journalID: id, zipSHA256: digest)], digest, [context, context])
            return expect(source, .documented, .documented, .unresolved, [.missingHistoricalContext])
        }
        check("04 wholly missing evidence is explicit STOPP, not vacuous success") {
            expect(input([], [], .missing), .unresolved, .unresolved, .unresolved, [.invalidZipHash, .missingJournal, .missingBaseline])
        }
        check("05 missing journal does not discard baseline record observations") {
            expect(input([baseline()], []), .unresolved, .documented, .documented, [.missingJournal])
        }
        check("06 duplicate baseline candidates remain ambiguous and preserved") {
            expect(input([baseline(), baseline()]), .ambiguous, .ambiguous, .ambiguous, [.multipleBaselines])
        }
        check("07 duplicate journal candidates remain ambiguous") {
            let j = M.Journal(journalID: id, zipSHA256: digest)
            return expect(input([baseline()], [j, j]), .ambiguous, .documented, .documented, [.multipleJournals])
        }
        check("08 independent journal ID mismatch") {
            expect(input([baseline([claim], records, .string("00000000-0000-0000-0000-000000000000"))]),
                .conflicting, .documented, .documented, [.journalIDMismatch])
        }
        check("09 independent selected ZIP mismatch") {
            expect(input([baseline()], [.init(journalID: id, zipSHA256: digest)], otherDigest),
                .conflicting, .documented, .documented, [.zipHashMismatch])
        }
        check("10 baseline ZIP mismatch with matching selected ZIP and journal") {
            expect(input([baseline([claim], records, id, otherDigest)]), .conflicting, .documented, .documented, [.zipHashMismatch])
        }
        check("11 invalid binding raw types, whitespace and malformed hashes are preserved") {
            let bad: [M.Raw] = [.missing, .nonString(type: "Int", description: "12"), .string(" "), .string("bad")]
            return bad.allSatisfy { raw in
                expect(input([baseline([claim], records, raw, raw)], [.init(journalID: raw, zipSHA256: raw)], raw),
                    .unresolved, .documented, .documented, [.invalidZipHash, .invalidJournalBinding, .invalidBaselineBinding])
            }
        }
        check("12 no records does not erase documented binding") {
            expect(input([baseline([claim], [])]), .documented, .unresolved, .documented, [.missingRecords])
        }
        check("13 missing, non-string, whitespace and control-character record fields are retained") {
            let bad: [M.Raw] = [.missing, .nonString(type: "Int", description: "4"), .string(""), .string("\n")]
            return bad.allSatisfy { raw in
                let r = M.Record(recordType: raw, recordName: raw, changeTag: raw)
                return expect(input([baseline([claim], [r])]), .documented, .unresolved, .documented, [.invalidRecord])
            }
        }
        check("14 identical record duplicates remain visible and ambiguous") {
            expect(input([baseline([claim], records + records)]), .documented, .ambiguous, .documented, [.repeatedRecordAddress])
        }
        check("15 contradictory changeTags STOPP, both observations preserved") {
            let r = M.Record(recordType: records[0].recordType, recordName: records[0].recordName, changeTag: .string("different"))
            return expect(input([baseline([claim], records + [r])]), .documented, .conflicting, .documented,
                [.repeatedRecordAddress, .conflictingRecordVersion])
        }
        check("16 all six historical context fields are required; source required separately") {
            let bad: [M.Raw] = [.missing, .string(" "), .nonString(type: "Bool", description: "true")]
            return bad.allSatisfy { raw in
                let contexts = context.fields.indices.map { index -> M.Context in
                    var fields = context.fields; fields[index] = raw
                    return .init(container: fields[0], environment: fields[1], account: fields[2],
                        database: fields[3], zone: fields[4], zoneOwner: fields[5])
                }
                return contexts.allSatisfy { c in expect(input([baseline([.init(context: c, evidenceSource: .string("source"))])]),
                    .documented, .documented, .unresolved, [.invalidHistoricalClaim]) } &&
                    expect(input([baseline([.init(context: context, evidenceSource: raw)])]),
                        .documented, .documented, .unresolved, [.invalidHistoricalClaim])
            }
        }
        check("17 identical historical claims are ambiguous, never silently deduplicated") {
            expect(input([baseline([claim, claim])]), .documented, .documented, .ambiguous, [.multipleHistoricalClaims])
        }
        check("18 contradictory historical contexts STOPP independently of current context") {
            let c = M.Context(container: context.container, environment: .string("Production"), account: context.account,
                database: context.database, zone: context.zone, zoneOwner: context.zoneOwner)
            return expect(input([baseline([claim, .init(context: c, evidenceSource: .string("source-2"))])],
                [.init(journalID: id, zipSHA256: digest)], digest, [context]), .documented, .documented, .conflicting,
                [.multipleHistoricalClaims, .conflictingHistoricalContexts])
        }
        check("19 current context neither validates nor invalidates explicit historical claim") {
            let c = M.Context(container: .missing, environment: .missing, account: .missing, database: .missing, zone: .missing, zoneOwner: .missing)
            return expect(input([baseline()], [.init(journalID: id, zipSHA256: digest)], digest, [c]),
                .documented, .documented, .documented, [])
        }
        check("20 exact comparison without case folding; unknown type and invalid tag STOPP") {
            let r = M.Record(recordType: .string("textile"), recordName: .string("untouched name"), changeTag: .string(" tag "))
            return expect(input([baseline([claim], [r])]), .documented, .unresolved, .documented, [.invalidRecord])
        }
        check("21 deterministic sorted observations/issues and immutable complete input") {
            let original = input([baseline([], records + records)])
            let before = original
            let a = M.evaluate(original)
            let b = M.evaluate(input([baseline([], Array((records + records).reversed()))]))
            return a == M.evaluate(original) && original == before && a.recordGroups == b.recordGroups && a.issues == b.issues &&
                expect(original, .documented, .ambiguous, .unresolved, [.repeatedRecordAddress, .missingHistoricalContext])
        }
        check("22 each record field is independently validated without normalization") {
            let invalid = [M.Record(recordType: .missing, recordName: .string("r"), changeTag: .string("tag")),
                M.Record(recordType: .string("Textile"), recordName: .missing, changeTag: .string("tag")),
                M.Record(recordType: .string("Textile"), recordName: .string("r"), changeTag: .missing)]
            return invalid.allSatisfy { expect(input([baseline([claim], [$0])]),
                .documented, .unresolved, .documented, [.invalidRecord]) }
        }
        check("23 simultaneous independent contradictions retain every STOPP reason") {
            let b = baseline([], records, .string("00000000-0000-0000-0000-000000000000"), otherDigest)
            return expect(input([b]), .conflicting, .documented, .unresolved,
                [.journalIDMismatch, .zipHashMismatch, .missingHistoricalContext])
        }
        print("\(count) PASS, 0 FAIL — synthetic evidence only; no import or writing authority.")
    }
}
