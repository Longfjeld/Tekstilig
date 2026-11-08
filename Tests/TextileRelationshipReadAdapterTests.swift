import Darwin

@main @MainActor
struct TextileRelationshipReadAdapterTests {
    typealias D = ImportIdentityReadDiagnostic
    typealias M = TextileRelationshipModel
    typealias A = TextileRelationshipReadAdapter
    static let scope = ImportIdentityDecisionModel.Scope(container: "fixture-container", environment: "Development", account: "fixture-account",
        database: "private", zone: "fixture-zone", zoneOwner: "fixture-owner")
    static let context = D.Context(scope: scope, environmentSource: .signedApplicationEntitlement, expectedEnvironment: .development)
    static let types = Set(ImportIdentityDecisionModel.RecordType.allCases)
    static var family: [D.Observation] {
        ImportIdentityDecisionModel.RecordType.allCases.map {
            record($0.rawValue, $0 == .textile ? .string("T-1") : .string("ID-" + $0.rawValue), .string("T-1"), "random-" + $0.rawValue)
        }
    }
    static func record(_ type: String, _ id: D.RawField, _ owner: D.RawField, _ name: String,
                       zone: String? = nil, zoneOwner: String? = nil, tag: String? = "tag") -> D.Observation {
        .init(recordType: type, logicalID: id, owner: owner, recordName: name,
            zone: zone ?? scope.zone, zoneOwner: zoneOwner ?? scope.zoneOwner, changeTag: tag)
    }
    // Outer nil selects the fixture default; .some(nil) explicitly models missing context.
    static func source(_ first: [D.Observation]? = nil, second: [D.Observation]? = nil, c: D.Context?? = nil,
                       firstTypes: Set<ImportIdentityDecisionModel.RecordType>? = nil,
                       secondTypes: Set<ImportIdentityDecisionModel.RecordType>? = nil, issues: [String] = []) -> D.ReadResult {
        let first = first ?? family
        return .init(context: c ?? context, first: first, second: second ?? first,
            firstTypes: firstTypes ?? types, secondTypes: secondTypes ?? types, issues: issues)
    }
    static func rows(_ result: A.Result, _ outcome: M.Outcome, count: Int = 4) -> Bool {
        [result.first, result.second].allSatisfy {
            $0.rows.count == count && $0.rows.allSatisfy { $0.observation.outcome == outcome } && !$0.permitsCloudKitWriting
        } && !result.permitsCloudKitWriting
    }
    static func retained(_ result: A.Result, _ source: D.ReadResult) -> Bool {
        result.source.context == source.context && result.source.first == source.first && result.source.second == source.second &&
            result.source.firstTypes == source.firstTypes && result.source.secondTypes == source.secondTypes && result.source.issues == source.issues
    }
    static func main() {
        var count = 0
        func check(_ name: String, _ test: () -> Bool) {
            guard test() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        check("01 full two-pass family maps exact raw fields, scopes, names, tags and unique parents") {
            let s = source(); let r = A.adapt(s)
            let ms = M.Scope(container: scope.container, environment: scope.environment, account: scope.account,
                database: scope.database, zone: scope.zone, zoneOwner: scope.zoneOwner)
            let parent = M.Parent(logicalID: .string("T-1"), recordName: "random-Textile", scope: ms, changeTag: "tag")
            let children = M.ChildType.allCases.map { M.Child(type: $0, logicalID: .string("ID-" + $0.rawValue), owner: .string("T-1"),
                recordName: "random-" + $0.rawValue, scope: ms, changeTag: "tag") }
            let expected = M.Input(parents: [parent], children: children,
                coverage: [.init(scope: ms, contextVerified: true, textileReadComplete: true, readIssues: [])])
            return retained(r, s) && r.firstInput == expected && r.secondInput == expected && r.issues.isEmpty && !r.hasStop &&
                rows(r, .uniqueObservedParent) && r.first.basis.rows.allSatisfy { $0.matchingParents == [parent] }
        }
        check("02 partial type coverage cannot prove unique or absent parent") {
            let r = A.adapt(source(firstTypes: [.textile], secondTypes: []))
            return rows(r, .incompleteCoverage) && r.hasStop && r.issues == ["Pass 1: ufullstendig typedekning", "Pass 2: ufullstendig typedekning"] &&
                r.firstInput.coverage.allSatisfy { !$0.textileReadComplete }
        }
        check("03 cancellation retains partial second pass and stops both reports") {
            let s = source(second: Array(family.prefix(1)), secondTypes: [], issues: ["Lesing avbrutt"])
            let r = A.adapt(s)
            return retained(r, s) && r.first.rows.count == 4 && r.second.rows.isEmpty && r.hasStop &&
                r.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } &&
                r.issues.contains("Lesing avbrutt") && r.firstInput.coverage[0].textileReadComplete == false
        }
        check("04 identical duplicate errors retained in source and coverage") {
            let s = source(issues: ["page failed", "page failed"]); let r = A.adapt(s)
            return retained(r, s) && r.issues == ["page failed", "page failed"] &&
                r.firstInput.coverage[0].readIssues == r.issues && rows(r, .incompleteCoverage)
        }
        check("05 changed tag between passes stops and preserves both versions") {
            var second = family; let v = second[1]
            second[1] = record(v.recordType, v.logicalID, v.owner, v.recordName, tag: "changed")
            let r = A.adapt(source(second: second))
            return rows(r, .incompleteCoverage) && r.issues == ["Observasjoner avviker mellom passeringene"] &&
                r.firstInput.children[0].changeTag == "tag" && r.secondInput.children[0].changeTag == "changed"
        }
        check("06 missing context preserves raw zones in source and gives no coverage") {
            let s = source(c: .some(nil)); let r = A.adapt(s)
            return retained(r, s) && rows(r, .incompleteCoverage) && r.firstInput.coverage.isEmpty &&
                r.firstInput.children.allSatisfy { $0.scope == nil } && r.issues == ["Uverifisert/manglende lesekontekst"]
        }
        check("07 unsigned or mismatched environment is unverified, never complete") {
            [D.Context(scope: scope, environmentSource: .unverified, expectedEnvironment: .development),
             D.Context(scope: scope, environmentSource: .signedApplicationEntitlement, expectedEnvironment: .production)].allSatisfy { c in
                let r = A.adapt(source(c: c))
                return rows(r, .incompleteCoverage) && !r.firstInput.coverage[0].contextVerified && !r.firstInput.coverage[0].textileReadComplete
            }
        }
        check("08 foreign zone is preserved, never granted requested-zone coverage") {
            let v = record("TextileImage", .string("foreign"), .string("T-1"), "foreign-image", zone: "other-zone", zoneOwner: "other-owner")
            let r = A.adapt(source(family + [v]))
            return rows(r, .incompleteCoverage, count: 5) && r.firstInput.children.last?.scope?.zone == "other-zone" &&
                r.firstInput.children.last?.scope?.zoneOwner == "other-owner" && r.firstInput.coverage.count == 1 && r.hasStop
        }
        check("09 duplicate parents preserved per pass, not merged between passes") {
            let s = source(family + [family[0]]); let r = A.adapt(s)
            return retained(r, s) && rows(r, .incompleteCoverage) && r.firstInput.parents.count == 2 &&
                r.first.basis.rows.allSatisfy { $0.matchingParents.count == 2 } && r.issues.count == 4
        }
        check("10 duplicate children preserve exact row multiplicity") {
            let r = A.adapt(source(family + [family[1]]))
            return rows(r, .incompleteCoverage, count: 5) && r.first.rows.filter { $0.observation.child.recordName == family[1].recordName }.count == 2
        }
        check("11 all raw field variants preserved without trimming") {
            let raw: [D.RawField] = [.missing, .string(" T0001\n"), .nonString(type: "Int", description: "7")]
            let expected: [M.RawField] = [.missing, .string(" T0001\n"), .nonString(type: "Int", description: "7")]
            return zip(raw, expected).allSatisfy { value, mapped in
                let v = record("TextileImage", value, value, "raw-image")
                let s = source([v]); let r = A.adapt(s)
                return retained(r, s) && rows(r, .invalidOwner, count: 1) && r.firstInput.children[0].logicalID == mapped &&
                    r.firstInput.children[0].owner == mapped && r.hasStop
            }
        }
        check("12 unknown type retained in source with explicit STOPP, no invented child type") {
            let v = record("Unknown", .string("U"), .string("T-1"), "unknown")
            let s = source(family + [v]); let r = A.adapt(s)
            return retained(r, s) && rows(r, .incompleteCoverage) && r.issues.count == 2 && r.hasStop
        }
        check("13 T0001 absence is a scoped observation, never historical deletion") {
            let v = record("TextileImage", .string("IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC"), .string("T0001"), "74B85BA7-9EBF-48FD-A04A-828329F9B237")
            let r = A.adapt(source([v]))
            return rows(r, .parentNotObservedWithCompleteCoverage, count: 1) && r.issues.isEmpty && r.hasStop &&
                r.firstInput.coverage[0].textileReadComplete && r.first.rows[0].explanation.contains("beviser ikke historisk sletting")
        }
        check("14 incomplete T0001 never proves missing parent") {
            let v = record("TextileImage", .string("IMG"), .string("T0001"), "image")
            let r = A.adapt(source([v], firstTypes: [.image], secondTypes: [.image]))
            return rows(r, .incompleteCoverage, count: 1) && r.hasStop
        }
        check("15 exact PoC records remain observed and can have explicit parent relationships") {
            let values = [record("Textile", .string("T-POC"), .string("T-POC"), "swiftui-poc-textile-v1"),
                record("Piece", .string("P-POC"), .string("T-POC"), "swiftui-poc-piece-v1"),
                record("TextileImage", .string("I-POC"), .string("T-POC"), "swiftui-poc-textile-image-v1")]
            let r = A.adapt(source(values))
            return rows(r, .uniqueObservedParent, count: 2) && r.firstInput.parents.count == 1 && !r.hasStop
        }
        check("16 missing tag stops even if supplied issues and completion flags look valid") {
            let v = record("TextileImage", .string("IMG"), .string("T-1"), "image", tag: nil)
            let r = A.adapt(source(family + [v]))
            return rows(r, .incompleteCoverage, count: 5) && r.firstInput.children.last?.changeTag == nil && r.hasStop
        }
        check("17 cross-type same physical record name is a collision") {
            let v = record("TextileImage", .string("IMG"), .string("T-1"), family[0].recordName)
            let r = A.adapt(source(family + [v]))
            return rows(r, .incompleteCoverage, count: 5) && r.issues.count == 2 && r.hasStop
        }
        check("18 missing record in second pass retains exact pass multiplicities") {
            let r = A.adapt(source(second: Array(family.dropLast())))
            return r.first.rows.count == 4 && r.second.rows.count == 3 && r.hasStop &&
                r.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } &&
                r.second.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage }
        }
        check("19 order-independent mapped reports and errors, original input unchanged") {
            let s = source(family + [family[1]], issues: ["b", "a", "a"])
            let a = A.adapt(s), b = A.adapt(source(Array(s.first.reversed()), issues: ["a", "b", "a"]))
            return retained(a, s) && a.first == b.first && a.second == b.second && a.issues == b.issues &&
                a.first.rows.count == 5 && !a.permitsCloudKitWriting
        }
        check("20 contradictory Textile owner retained, no complete coverage") {
            let p = record("Textile", .string("T-1"), .string("other"), "parent")
            let s = source([p] + family.dropFirst()); let r = A.adapt(s)
            return retained(r, s) && rows(r, .incompleteCoverage) && r.issues.count == 2 && r.hasStop
        }
        check("21 empty or fully aborted result never reports complete relations") {
            let r = A.adapt(source([], c: .some(nil), firstTypes: [], secondTypes: [], issues: ["Lesing avbrutt"]))
            return r.first.rows.isEmpty && r.second.rows.isEmpty && r.hasStop && !r.permitsCloudKitWriting && r.firstInput.coverage.isEmpty
        }
        print("\(count) PASS, 0 FAIL — synthetic ReadResult only; no transport or writing.")
    }
}
