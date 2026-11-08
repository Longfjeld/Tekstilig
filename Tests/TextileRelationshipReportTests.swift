import Darwin

@main
struct TextileRelationshipReportTests {
    typealias M = TextileRelationshipModel
    typealias R = TextileRelationshipReport
    static let scope = M.Scope(container: "fixture-container", environment: "Development", account: "fixture-account",
        database: "private", zone: "fixture-zone", zoneOwner: "fixture-owner")
    static let other = M.Scope(container: "fixture-container", environment: "Development", account: "other-account",
        database: "private", zone: "fixture-zone", zoneOwner: "fixture-owner")
    static func parent(_ id: M.RawField = .string("T-1"), _ name: String = "parent-a", _ context: M.Scope? = scope) -> M.Parent {
        .init(logicalID: id, recordName: name, scope: context, changeTag: "parent-tag")
    }
    static func child(_ type: M.ChildType, _ id: String, _ owner: M.RawField = .string("T-1"), _ context: M.Scope? = scope) -> M.Child {
        .init(type: type, logicalID: .string(id), owner: owner, recordName: "record-" + id, scope: context, changeTag: "child-tag")
    }
    static var children: [M.Child] { M.ChildType.allCases.map { child($0, $0.rawValue) } }
    static func coverage(_ context: M.Scope = scope, verified: Bool = true, complete: Bool = true, issues: [String] = []) -> M.Coverage {
        .init(scope: context, contextVerified: verified, textileReadComplete: complete, readIssues: issues)
    }
    static func make(_ children: [M.Child], _ parents: [M.Parent] = [parent()], _ coverage: [M.Coverage] = [coverage()]) -> R.Report {
        R.make(.init(parents: parents, children: children, coverage: coverage))
    }
    static func allRows(_ report: R.Report, _ expected: [M.Child], outcome: M.Outcome, matches: [M.Parent], reasons: [M.Reason] = []) -> Bool {
        let expectedRows = expected.map { M.Row(child: $0, matchingParents: matches, outcome: outcome,
            reasons: reasons.sorted { $0.rawValue < $1.rawValue }) }.sorted { $0.child.order.lexicographicallyPrecedes($1.child.order) }
        return report.rows.count == expected.count && report.rows.map(\.observation) == expectedRows &&
            report.rows.allSatisfy { !$0.explanation.isEmpty && report.text.contains($0.text) } && !report.permitsCloudKitWriting
    }
    static func main() {
        var count = 0
        func check(_ name: String, _ body: () -> Bool) {
            guard body() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        check("01 empty input is STOPP/no observations and never vacuous success") {
            let r = make([], [], [])
            return r.rows.isEmpty && r.hasStops && !r.permitsCloudKitWriting && r.text.contains("STOPP: Ingen underpostobservasjoner")
        }
        check("02 exact four rows, type counts and explicit deterministic type order") {
            let r = make(children)
            return allRows(r, children, outcome: .uniqueObservedParent, matches: [parent()]) && !r.hasStops &&
                r.rows.map { $0.observation.child.type } == [.piece, .color, .image, .material] &&
                M.ChildType.allCases.allSatisfy { r.text.contains("Antall \($0.rawValue): 1") } && r.text.contains("Underpostrader: 4;")
        }
        check("03 duplicate children keep exact row multiplicity in structure and text") {
            let r = make(children + children)
            return allRows(r, children + children, outcome: .uniqueObservedParent, matches: [parent()]) &&
                r.rows.allSatisfy { row in r.text.split(separator: "\n").filter { $0 == Substring(row.text) }.count == 2 }
        }
        check("04 each row includes all six exact context fields and physical metadata") {
            let r = make(children)
            return r.rows.allSatisfy { row in
                scope.fields.allSatisfy { row.text.contains($0.debugDescription) } &&
                    row.text.contains("recordName: \(row.observation.child.recordName.debugDescription)") &&
                    row.text.contains("changeTag: \"child-tag\"") && row.text.contains("foreldretreff: 1") &&
                    row.text.contains("parent-a") && row.text.contains("parent-tag")
            }
        }
        check("05 ambiguous parents preserve all hits and select none") {
            let parents = [parent(), parent(.string("T-1"), "parent-b")]
            let r = make(children, parents)
            return allRows(r, children, outcome: .ambiguousParent, matches: parents) && r.hasStops &&
                r.rows.allSatisfy { $0.hasStop && $0.text.contains("foreldretreff: 2") && $0.explanation.contains("ingen forelder er valgt") }
        }
        check("06 identical parent duplicates remain visible in full basis and each row") {
            let r = make(children, [parent(), parent()])
            return allRows(r, children, outcome: .ambiguousParent, matches: [parent(), parent()]) &&
                r.basis.parents == [parent(), parent()] && r.text.contains("foreldreobservasjoner: 2;")
        }
        check("07 invalid raw owners are retained and concretely explained for every subtype") {
            let owners: [M.RawField] = [.missing, .nonString(type: "Number", description: "42|raw\n"), .string(" T-1\n")]
            return owners.allSatisfy { owner in
                let values = M.ChildType.allCases.map { child($0, $0.rawValue, owner) }
                let r = make(values)
                return allRows(r, values, outcome: .invalidOwner, matches: [], reasons: [.invalidOwner]) && r.hasStops &&
                    r.rows.allSatisfy { $0.hasStop && !$0.text.contains("\n") && $0.text.contains("invalidOwner") }
            }
        }
        check("08 incomplete coverage and duplicate error strings are never omitted") {
            let c = coverage(complete: false, issues: ["b", "a", "a"])
            let r = make(children, [parent()], [c])
            return allRows(r, children, outcome: .incompleteCoverage, matches: [parent()], reasons: [.incompleteTextileRead, .readIssues]) &&
                r.hasStops && r.basis.coverage[0].readIssues == ["a", "a", "b"] &&
                r.text.contains("Textile-lesing komplett: false") && r.text.contains("lesefeil: [\"a\", \"a\", \"b\"]")
        }
        check("09 absent/unverified/duplicate coverage gets exact STOPP reasons") {
            let cases: [([M.Coverage], M.Reason)] = [([], .missingCoverage), ([coverage(verified: false)], .unverifiedContext),
                ([coverage(), coverage()], .ambiguousCoverage)]
            return cases.allSatisfy { values, reason in
                let r = make(children, [parent()], values)
                return allRows(r, children, outcome: .incompleteCoverage, matches: [parent()], reasons: [reason]) &&
                    r.hasStops && r.basis.coverage.count == values.count && r.rows.allSatisfy { $0.text.contains(reason.rawValue) }
            }
        }
        check("10 missing child context and unscoped/invalid parent basis remain visible") {
            let values = [child(.image, "image", .string("T-1"), nil)]
            let a = make(values)
            let b = make(children, [parent(.missing, "invalid-parent", nil)])
            let c = make(children, [parent(.missing)])
            return allRows(a, values, outcome: .incompleteCoverage, matches: [], reasons: [.missingOrInvalidChildScope]) &&
                a.rows[0].text.contains("kontekst: mangler") &&
                allRows(b, children, outcome: .incompleteCoverage, matches: [], reasons: [.unscopedParentObservation]) &&
                b.text.contains("invalid-parent") && b.text.contains("rå-ID: mangler") &&
                allRows(c, children, outcome: .incompleteCoverage, matches: [], reasons: [.invalidParentObservation])
        }
        check("11 another account is not a parent match or an inferred child context") {
            let r = make(children, [parent(.string("T-1"), "foreign", other)])
            return allRows(r, children, outcome: .parentNotObservedWithCompleteCoverage, matches: []) &&
                r.hasStops && r.basis.parents[0].scope == other && r.text.contains("other-account")
        }
        check("12 mixed five outcomes are attached to the exact five child identities") {
            let values = [child(.piece, "0"), child(.material, "1", .string("T-missing")),
                child(.color, "2", .string("T-dup")), child(.image, "3", .missing), child(.image, "4", .string("T-1"), other)]
            let duplicates = [parent(.string("T-dup"), "dup-a"), parent(.string("T-dup"), "dup-b")]
            let op = parent(.string("T-1"), "other-parent", other)
            let r = make(values, [parent(), op] + duplicates, [coverage(), coverage(other, complete: false)])
            let expected: [M.Row] = [.init(child: values[0], matchingParents: [parent()], outcome: .uniqueObservedParent, reasons: []),
                .init(child: values[2], matchingParents: duplicates, outcome: .ambiguousParent, reasons: []),
                .init(child: values[3], matchingParents: [], outcome: .invalidOwner, reasons: [.invalidOwner]),
                .init(child: values[4], matchingParents: [op], outcome: .incompleteCoverage, reasons: [.incompleteTextileRead]),
                .init(child: values[1], matchingParents: [], outcome: .parentNotObservedWithCompleteCoverage, reasons: [])]
            return r.rows.count == 5 && r.rows.map(\.observation) == expected && r.rows.map(\.hasStop) == [false, true, true, true, true] && r.hasStops
        }
        check("13 full structured/text reports repeat and survive reordered input") {
            let parents = [parent(.string("T-1"), "parent-b"), parent(), parent(.string("T-POC"), "swiftui-poc-textile-v1")]
            let c = [coverage(), coverage(other, complete: false, issues: ["b", "a", "a"])]
            let a = make(children + children, parents, c)
            let b = make(Array((children + children).reversed()), Array(parents.reversed()), c.reversed().map {
                M.Coverage(scope: $0.scope, contextVerified: $0.contextVerified, textileReadComplete: $0.textileReadComplete, readIssues: Array($0.readIssues.reversed())) })
            return a == b && a.text == b.text && a == make(children + children, parents, c) && a.basis.parents.count == 3 && a.rows.count == 8
        }
        check("14 T0001 missing parent is scoped observation, never historical proof") {
            let value = child(.image, "IMG-synthetic", .string("T0001"))
            let r = make([value], [])
            return allRows(r, [value], outcome: .parentNotObservedWithCompleteCoverage, matches: []) &&
                r.rows[0].text.contains("T0001") && r.rows[0].explanation.contains("beviser ikke historisk sletting eller datakorrupsjon") && r.hasStops
        }
        check("15 no mutation, write authority, or import approval for any result") {
            let input = M.Input(parents: [parent()], children: children, coverage: [coverage()])
            let original = input; let r = R.make(input)
            return input == original && !r.permitsCloudKitWriting && !r.basis.permitsCloudKitWriting &&
                r.text.contains("CloudKit-skrivetillatelse: false") && r.text.contains("Ingen importbeslutning") &&
                r.text.contains("underpost-ID eller versjoner")
        }
        print("\(count) PASS, 0 FAIL – synthetic relationship reporting only; test 242.2 awaits user validation.")
    }
}
