import Darwin

@main
struct TextileRelationshipModelTests {
    typealias M = TextileRelationshipModel
    static let scope = M.Scope(container: "synthetic", environment: "Development", account: "account",
        database: "private", zone: "zone", zoneOwner: "zone-owner")
    static func changedScope(_ index: Int, _ value: String) -> M.Scope {
        var fields = scope.fields; fields[index] = value
        return M.Scope(container: fields[0], environment: fields[1], account: fields[2], database: fields[3], zone: fields[4], zoneOwner: fields[5])
    }
    static func parent(_ id: M.RawField = .string("T-1"), name: String = "parent-a", context: M.Scope? = scope) -> M.Parent {
        M.Parent(logicalID: id, recordName: name, scope: context, changeTag: "parent-tag")
    }
    static func children(_ owner: M.RawField = .string("T-1"), context: M.Scope? = scope) -> [M.Child] {
        M.ChildType.allCases.map {
            M.Child(type: $0, logicalID: .string("ID-\($0.rawValue)"), owner: owner,
                recordName: "child-\($0.rawValue)", scope: context, changeTag: "child-tag")
        }
    }
    static func coverage(_ context: M.Scope = scope, verified: Bool = true, complete: Bool = true, issues: [String] = []) -> M.Coverage {
        M.Coverage(scope: context, contextVerified: verified, textileReadComplete: complete, readIssues: issues)
    }
    // Exact rows, raw child values, matches, outcome and reasons; empty/extra rows cannot pass.
    static func expect(_ input: M.Input, _ outcome: M.Outcome, matches: [M.Parent] = [], reasons: [M.Reason] = []) -> Bool {
        let rows = input.children.map {
            M.Row(child: $0, matchingParents: matches, outcome: outcome, reasons: reasons.sorted { $0.rawValue < $1.rawValue })
        }.sorted { $0.child.order.lexicographicallyPrecedes($1.child.order) }
        let expectedCoverage = input.coverage.map {
            M.Coverage(scope: $0.scope, contextVerified: $0.contextVerified, textileReadComplete: $0.textileReadComplete, readIssues: $0.readIssues.sorted())
        }.sorted { $0.order.lexicographicallyPrecedes($1.order) }
        let report = M.evaluate(input)
        return report == M.Report(parents: input.parents.sorted { $0.order.lexicographicallyPrecedes($1.order) },
            coverage: expectedCoverage, rows: rows) && report.rows.count == input.children.count && !report.permitsCloudKitWriting
    }
    static func main() {
        var count = 0
        func check(_ name: String, _ body: () -> Bool) {
            guard body() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        check("01 empty input stays empty and authorizes nothing") {
            let r = M.evaluate(.init(parents: [], children: [], coverage: []))
            return r == .init(parents: [], coverage: [], rows: []) && !r.permitsCloudKitWriting
        }
        check("02 all four types have exact unique parent and raw identities") {
            children().count == 4 && expect(.init(parents: [parent()], children: children(), coverage: [coverage()]),
                .uniqueObservedParent, matches: [parent()])
        }
        check("03 complete scoped coverage allows only not-observed, never deleted") {
            expect(.init(parents: [], children: children(), coverage: [coverage()]), .parentNotObservedWithCompleteCoverage)
        }
        check("04 incomplete Textile read never proves missing parent") {
            expect(.init(parents: [], children: children(), coverage: [coverage(complete: false)]),
                .incompleteCoverage, reasons: [.incompleteTextileRead])
        }
        check("05 one observed parent cannot conceal incomplete coverage") {
            expect(.init(parents: [parent()], children: children(), coverage: [coverage(complete: false)]),
                .incompleteCoverage, matches: [parent()], reasons: [.incompleteTextileRead])
        }
        check("06 duplicate logical parent with different names is ambiguous for every type") {
            let parents = [parent(), parent(name: "parent-b")]
            return expect(.init(parents: parents, children: children(), coverage: [coverage()]), .ambiguousParent, matches: parents)
        }
        check("07 identical duplicate observations are retained, never silently deduplicated") {
            expect(.init(parents: [parent(), parent()], children: children(), coverage: [coverage()]),
                .ambiguousParent, matches: [parent(), parent()])
        }
        check("08 invalid raw owners preserved on all four types without normalization") {
            let owners: [M.RawField] = [.missing, .nonString(type: "Number", description: "7"), .string(""),
                .string(" T-1"), .string("T-1 "), .string("T-1\n"), .string("T-é")]
            return owners.allSatisfy {
                expect(.init(parents: [parent()], children: children($0), coverage: [coverage()]), .invalidOwner, reasons: [.invalidOwner])
            }
        }
        check("09 absent child context remains unresolved even with a matching-looking ID") {
            expect(.init(parents: [parent()], children: children(context: nil), coverage: [coverage()]),
                .incompleteCoverage, reasons: [.missingOrInvalidChildScope])
        }
        check("10 each context component is preserved and invalid blanks stop") {
            (0..<6).allSatisfy { index in
                expect(.init(parents: [], children: children(context: changedScope(index, "")), coverage: [coverage()]),
                    .incompleteCoverage, reasons: [.missingOrInvalidChildScope])
            }
        }
        check("11 container/environment/account/database/zone/owner prevent cross-scope matches") {
            (0..<6).allSatisfy { index in
                let other = changedScope(index, "other")
                return expect(.init(parents: [parent(context: other)], children: children(), coverage: [coverage()]),
                    .parentNotObservedWithCompleteCoverage) &&
                    expect(.init(parents: [parent()], children: children(context: other), coverage: [coverage()]),
                        .incompleteCoverage, reasons: [.missingCoverage])
            }
        }
        check("12 missing coverage cannot be inferred from observations") {
            expect(.init(parents: [parent()], children: children(), coverage: []),
                .incompleteCoverage, matches: [parent()], reasons: [.missingCoverage])
        }
        check("13 syntactically valid context is not automatically verified") {
            expect(.init(parents: [parent()], children: children(), coverage: [coverage(verified: false)]),
                .incompleteCoverage, matches: [parent()], reasons: [.unverifiedContext])
        }
        check("14 duplicate coverage claims remain ambiguous even if identical") {
            expect(.init(parents: [], children: children(), coverage: [coverage(), coverage()]),
                .incompleteCoverage, reasons: [.ambiguousCoverage])
        }
        check("15 read errors are retained with deterministic order and stop") {
            let input = M.Input(parents: [parent()], children: children(), coverage: [coverage(issues: ["b", "a", "a"])])
            return expect(input, .incompleteCoverage, matches: [parent()], reasons: [.readIssues]) &&
                M.evaluate(input).coverage[0].readIssues == ["a", "a", "b"]
        }
        check("16 parent without context cannot be assumed irrelevant") {
            expect(.init(parents: [parent(context: nil)], children: children(), coverage: [coverage()]),
                .incompleteCoverage, reasons: [.unscopedParentObservation])
        }
        check("17 malformed parent context cannot be excluded from current scope") {
            expect(.init(parents: [parent(context: changedScope(4, " "))], children: children(), coverage: [coverage()]),
                .incompleteCoverage, reasons: [.unscopedParentObservation])
        }
        check("18 invalid parent identity prevents false absence in its scope") {
            let raw: [M.RawField] = [.missing, .nonString(type: "Number", description: "1"), .string(" T-1")]
            return raw.allSatisfy {
                expect(.init(parents: [parent($0)], children: children(), coverage: [coverage()]),
                    .incompleteCoverage, reasons: [.invalidParentObservation])
            }
        }
        check("19 invalid physical parent record name stops without replacing it") {
            ["", String(repeating: "a", count: 256), "name\n"].allSatisfy { name in
                let p = parent(name: name)
                return expect(.init(parents: [p], children: children(), coverage: [coverage()]),
                    .incompleteCoverage, matches: [p], reasons: [.invalidParentObservation])
            }
        }
        check("20 raw invalid observations in a known different scope remain visible") {
            expect(.init(parents: [parent(.missing, context: changedScope(2, "other-account"))],
                children: children(), coverage: [coverage()]), .parentNotObservedWithCompleteCoverage)
        }
        check("21 T0001 is not a deletion/corruption inference and can have an observed parent") {
            let child = M.Child(type: .image, logicalID: .string("IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC"),
                owner: .string("T0001"), recordName: "74B85BA7-9EBF-48FD-A04A-828329F9B237", scope: scope, changeTag: "synthetic-tag")
            let p = parent(.string("T0001"))
            return expect(.init(parents: [], children: [child], coverage: [coverage()]), .parentNotObservedWithCompleteCoverage) &&
                expect(.init(parents: [], children: [child], coverage: [coverage(complete: false)]), .incompleteCoverage, reasons: [.incompleteTextileRead]) &&
                expect(.init(parents: [p], children: [child], coverage: [coverage()]), .uniqueObservedParent, matches: [p])
        }
        check("22 case is not normalized in owner matching") {
            expect(.init(parents: [parent(.string("T0001"))], children: children(.string("t0001")), coverage: [coverage()]),
                .parentNotObservedWithCompleteCoverage)
        }
        check("23 invalid owner takes explicit precedence over missing context/coverage") {
            expect(.init(parents: [], children: children(.missing, context: nil), coverage: []), .invalidOwner, reasons: [.invalidOwner])
        }
        check("24 relation outcome does not claim that child identity or versions are valid") {
            let child = M.Child(type: .image, logicalID: .nonString(type: "Number", description: "42"), owner: .string("T-1"),
                recordName: " raw child name ", scope: scope, changeTag: nil)
            return expect(.init(parents: [parent()], children: [child], coverage: [coverage()]), .uniqueObservedParent, matches: [parent()])
        }
        check("25 full reports repeat/reorder deterministically and preserve all source values") {
            let input = M.Input(parents: [parent(name: "parent-b"), parent(), parent(.string("T-POC"), name: "swiftui-poc-textile-v1")],
                children: children() + children(), coverage: [coverage(), coverage(changedScope(4, "other-zone"), issues: ["b", "a"])])
            let original = input
            let reversed = M.Input(parents: Array(input.parents.reversed()), children: Array(input.children.reversed()),
                coverage: input.coverage.reversed().map { M.Coverage(scope: $0.scope, contextVerified: $0.contextVerified,
                    textileReadComplete: $0.textileReadComplete, readIssues: Array($0.readIssues.reversed())) })
            let report = M.evaluate(input)
            return report == M.evaluate(input) && report == M.evaluate(reversed) && input == original &&
                report.parents.count == 3 && report.rows.count == 8 && report.coverage.count == 2 && !report.permitsCloudKitWriting
        }
        print("\(count) PASS, 0 FAIL – synthetic value-only relationships; test 242.1 awaits user validation.")
    }
}
