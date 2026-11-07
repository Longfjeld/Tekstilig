import Darwin

// Standalone executable: compile with the actual app model, never a copy.
@main
struct ImportIdentityDecisionModelTests {
    typealias M = ImportIdentityDecisionModel
    typealias Decisions = [M.Key: M.Decision]
    static let scope = M.Scope(container: "synthetic", environment: "test", account: "fixture",
        database: "private", zone: "default", zoneOwner: "fixture")
    static let hash = String(repeating: "a", count: 64)
    static let journalID = "00000000-0000-0000-0000-000000000001"
    static let parent = identity(.textile, "T-1", "T-1")
    static let coverage = M.Coverage(verifiedIdentityTypes: Set(M.RecordType.allCases),
        completeNameInventory: true, completeVersions: true, readErrors: [])

    static func identity(_ type: M.RecordType, _ id: String, _ owner: String) -> M.Identity {
        M.Identity(key: M.Key(type: type, logicalID: id), owner: owner)
    }
    static func observed(_ value: M.Identity, _ name: String, in context: M.Scope = scope) -> M.Observed {
        M.Observed(identity: value, address: M.Address(scope: context, recordName: name))
    }
    static func inventory(_ value: M.Observed) -> M.InventoryRecord {
        M.InventoryRecord(type: value.identity.key.type, address: value.address)
    }
    static func versions(_ records: [M.InventoryRecord]) -> [M.Version] {
        records.map { M.Version(record: $0, changeTag: "tag-1") }
    }
    static func binding(_ keys: [M.Key], state: M.OperationState = .planned) -> M.Binding {
        M.Binding(selectedZIPHash: hash, journalZIPHash: hash, expectedJournalID: journalID,
            journalID: journalID, baselineJournalID: journalID, baselineZIPHash: hash,
            operations: keys.map { M.Operation(key: $0, state: state) })
    }
    static func altered(_ b: M.Binding, selected: String? = nil, journalHash: String? = nil,
                        expectedID: String? = nil, actualID: String? = nil, baselineID: String? = nil,
                        baselineHash: String? = nil, operations: [M.Operation]? = nil) -> M.Binding {
        M.Binding(selectedZIPHash: selected ?? b.selectedZIPHash, journalZIPHash: journalHash ?? b.journalZIPHash,
            expectedJournalID: expectedID ?? b.expectedJournalID, journalID: actualID ?? b.journalID,
            baselineJournalID: baselineID ?? b.baselineJournalID, baselineZIPHash: baselineHash ?? b.baselineZIPHash,
            operations: operations ?? b.operations)
    }
    static func input(_ backup: [M.Identity], _ live: [M.Observed] = [],
                      extra: [M.InventoryRecord] = []) -> M.Input {
        let records = live.map(inventory) + extra
        let existingParents = Set(live.filter { $0.identity.key.type == .textile }.map { $0.identity.key.logicalID })
        let newParents = Set(backup.filter { $0.key.type == .textile && !existingParents.contains($0.key.logicalID) }.map { $0.key.logicalID })
        let operations = Set(backup.filter { newParents.contains($0.owner) }.map(\.key)).sorted()
        return M.Input(scope: scope, backup: backup, observed: live, inventory: records,
            baseline: versions(records), current: versions(records), binding: binding(operations), coverage: coverage)
    }
    // Double optionals let a fixture explicitly remove evidence, without IO.
    static func replacing(_ value: M.Input, baseline: [M.Version]?? = nil, current: [M.Version]?? = nil,
                          binding: M.Binding?? = nil, coverage: M.Coverage? = nil,
                          inventory: [M.InventoryRecord]? = nil) -> M.Input {
        M.Input(scope: value.scope, backup: value.backup, observed: value.observed,
            inventory: inventory ?? value.inventory, baseline: baseline ?? value.baseline,
            current: current ?? value.current, binding: binding ?? value.binding, coverage: coverage ?? value.coverage)
    }
    static func ordered(_ stops: [M.Stop]) -> [M.Stop] { Set(stops).sorted() }
    static func matches(_ report: M.Report, input: M.Input, decisions: Decisions,
                        global: [M.Stop] = []) -> Bool {
        let keys = Set(input.backup.map(\.key))
        // Neither an empty/partial result nor duplicate/extra rows may pass.
        guard Set(decisions.keys) == keys, report.rows.count == keys.count,
              report.rows.map(\.key) == keys.sorted(), !report.permitsCloudKitWriting else { return false }
        let expected = M.Report(rows: keys.sorted().map { M.Row(key: $0, decision: decisions[$0]!) },
            globalStops: ordered(global))
        return report == expected
    }
    static func expect(_ input: M.Input, _ decisions: Decisions, global: [M.Stop] = []) -> Bool {
        matches(M.evaluate(input), input: input, decisions: decisions, global: global)
    }
    static func expectGlobal(_ value: M.Input, invalid: [M.Stop] = [], conflicts: [M.Stop] = []) -> Bool {
        guard !invalid.isEmpty || !conflicts.isEmpty else { return false }
        let decision: M.Decision = invalid.isEmpty ? .stopConflict(ordered(conflicts)) : .stopInvalidBasis(ordered(invalid))
        let decisions = Dictionary(uniqueKeysWithValues: Set(value.backup.map(\.key)).map { ($0, decision) })
        return expect(value, decisions, global: invalid + conflicts)
    }
    static func reuse(_ values: [M.Observed]) -> Decisions {
        Dictionary(uniqueKeysWithValues: values.map { ($0.identity.key, .reuseExisting($0)) })
    }
    static func candidates(_ values: [M.Identity]) -> Decisions {
        Dictionary(uniqueKeysWithValues: values.map { value in
            (value.key, .candidateForCreation(M.Candidate(identity: value,
                address: M.Address(scope: scope, recordName: M.candidateName(for: value.key)),
                strategyVersion: "diagnostic-hex-v1-provisional",
                parent: value.key.type == .textile ? nil : M.Key(type: .textile, logicalID: value.owner))))
        })
    }
    static func reordered(_ value: M.Input) -> M.Input {
        let b = value.binding.map { altered($0, operations: $0.operations.reversed()) }
        return M.Input(scope: value.scope, backup: value.backup.reversed(), observed: value.observed.reversed(),
            inventory: value.inventory.reversed(), baseline: value.baseline.map { $0.reversed() },
            current: value.current.map { $0.reversed() }, binding: b, coverage: value.coverage)
    }
    static func otherScope(zone: String = "default", account: String = "fixture") -> M.Scope {
        M.Scope(container: scope.container, environment: scope.environment, account: account,
            database: scope.database, zone: zone, zoneOwner: scope.zoneOwner)
    }

    static func main() {
        var passed = 0
        var failed = 0
        func test(_ name: String, _ check: () -> Bool) {
            if check() { passed += 1; print("PASS \(name)") }
            else { failed += 1; print("FAIL \(name)") }
        }
        let family = [parent] + M.RecordType.allCases.filter { $0 != .textile }.map { identity($0, "ID-\($0.rawValue)", "T-1") }
        let liveFamily = family.enumerated().map { observed($0.element, "random-existing-\($0.offset)") }
        let fresh = input(family)
        let stable = input(family, liveFamily)
        let newDecisions = candidates(family)
        let oldDecisions = reuse(liveFamily)
        let pocPairs: [(M.RecordType, String)] = [(.textile, "swiftui-poc-textile-v1"),
            (.piece, "swiftui-poc-piece-v1"), (.image, "swiftui-poc-textile-image-v1")]

        test("01 exact reuse of all five existing identities and record names") { expect(stable, oldDecisions) }
        test("02 exact candidates, parent dependencies and provisional name vectors") {
            let names: [M.RecordType: String] = [
                .textile: "tekstilig-import-v1-54657874696c653a542d31",
                .piece: "tekstilig-import-v1-50696563653a49442d5069656365",
                .material: "tekstilig-import-v1-54657874696c654d6174657269616c3a49442d54657874696c654d6174657269616c",
                .color: "tekstilig-import-v1-54657874696c65436f6c6f723a49442d54657874696c65436f6c6f72",
                .image: "tekstilig-import-v1-54657874696c65496d6167653a49442d54657874696c65496d616765"]
            return expect(fresh, newDecisions) && family.allSatisfy {
                guard case .candidateForCreation(let c) = newDecisions[$0.key] else { return false }
                return names[$0.key.type] == c.address.recordName && !c.approvedForProduction
            }
        }
        test("03 exact positive reports repeat and survive reversed input") {
            expect(fresh, newDecisions) && expect(reordered(fresh), newDecisions) &&
                expect(stable, oldDecisions) && expect(reordered(stable), oldDecisions) && M.evaluate(fresh) == M.evaluate(fresh)
        }
        test("04 duplicate backup ID, exact conflict key (each type)") {
            family.allSatisfy { expectGlobal(input(family + [$0]), conflicts: [M.Stop(.duplicateBackupID, key: $0.key)]) }
        }
        test("05 duplicate observed ID with different names (each type)") {
            family.allSatisfy { expectGlobal(input(family, liveFamily + [observed($0, "second-name")]),
                conflicts: [M.Stop(.duplicateObservedID, key: $0.key)]) }
        }
        test("06 exact owner conflict on each child, parent still observation-only reuse") {
            family.dropFirst().allSatisfy { child in
                let bad = observed(identity(child.key.type, child.key.logicalID, "T-other"), "child")
                return expect(input([parent, child], [liveFamily[0], bad]), [
                    parent.key: .reuseExisting(liveFamily[0]), child.key: .stopConflict([M.Stop(.ownerConflict, key: child.key, address: bad.address)])])
            }
        }
        test("07 missing parent, exact child decision (each child type)") {
            family.dropFirst().allSatisfy { expect(input([$0]), [$0.key: .stopConflict([M.Stop(.missingParent, key: parent.key)])]) }
        }
        test("08 ambiguous parent globally stops all family rows") {
            expectGlobal(input(family, [liveFamily[0], observed(parent, "second-parent")]), conflicts: [M.Stop(.duplicateObservedID, key: parent.key)])
        }
        test("09 exact candidate collision with fully observed same/other type") {
            family.allSatisfy { target in
                [target.key.type, target.key.type == .piece ? .textile : .piece].allSatisfy { type in
                    let extraID = identity(type, "occupied-ID", type == .textile ? "occupied-ID" : "T-other")
                    let extra = observed(extraID, M.candidateName(for: target.key))
                    var expected = newDecisions
                    expected[target.key] = .stopConflict([M.Stop(.candidateNameCollision, key: target.key, address: extra.address)])
                    if target.key.type == .textile {
                        for child in family.dropFirst() { expected[child.key] = .stopConflict([M.Stop(.parentStopped, key: parent.key)]) }
                    }
                    return expect(input(family, [extra]), expected)
                }
            }
        }
        test("10 exact PoC filter matches remain occupied AND identity-unresolved") {
            pocPairs.allSatisfy { type, name in
                let r = M.InventoryRecord(type: type, address: M.Address(scope: scope, recordName: name))
                return M.nameConflicts(proposed: r.address, inventory: [r]) &&
                    expectGlobal(input(family, extra: [r]), invalid: [M.Stop(.unresolvedFilteredIdentity, address: r.address)])
            }
        }
        test("11 changed baseline tag, exact reason") {
            let changed = stable.current!.enumerated().map { M.Version(record: $0.element.record, changeTag: $0.offset == 0 ? "tag-2" : "tag-1") }
            return expectGlobal(replacing(stable, current: .some(changed)), invalid: [M.Stop(.baselineChanged)])
        }
        test("12 added/deleted version relative to baseline") {
            let extra = M.InventoryRecord(type: .image, address: M.Address(scope: scope, recordName: "extra"))
            return expectGlobal(replacing(stable, baseline: .some(stable.baseline! + versions([extra]))), invalid: [M.Stop(.baselineChanged)]) &&
                expectGlobal(replacing(stable, baseline: .some(Array(stable.baseline!.dropFirst()))), invalid: [M.Stop(.baselineChanged)])
        }
        test("13 exact missing-tag addresses; missing baseline/current") {
            let bad = stable.current!.map { M.Version(record: $0.record, changeTag: "") }
            return expectGlobal(replacing(stable, current: .some(bad)),
                invalid: [M.Stop(.baselineChanged)] + bad.map { M.Stop(.missingVersionTag, address: $0.record.address) }) &&
                expectGlobal(replacing(stable, baseline: .some(nil)), invalid: [M.Stop(.missingBaseline)]) &&
                expectGlobal(replacing(stable, current: .some(nil)), invalid: [M.Stop(.missingBaseline)])
        }
        test("14 incomplete type/name/version coverage and read errors") {
            let coverages = [
                M.Coverage(verifiedIdentityTypes: [.textile], completeNameInventory: true, completeVersions: true, readErrors: []),
                M.Coverage(verifiedIdentityTypes: Set(M.RecordType.allCases), completeNameInventory: false, completeVersions: true, readErrors: []),
                M.Coverage(verifiedIdentityTypes: Set(M.RecordType.allCases), completeNameInventory: true, completeVersions: false, readErrors: []),
                M.Coverage(verifiedIdentityTypes: Set(M.RecordType.allCases), completeNameInventory: true, completeVersions: true, readErrors: ["failure"])]
            return coverages.allSatisfy { expectGlobal(replacing(fresh, coverage: $0), invalid: [M.Stop(.incompleteCoverage)]) }
        }
        test("15 wrong ZIP hash, wrong journal ID, absent binding") {
            expectGlobal(replacing(fresh, binding: .some(altered(fresh.binding!, selected: String(repeating: "b", count: 64)))), invalid: [M.Stop(.invalidBinding)]) &&
                expectGlobal(replacing(fresh, binding: .some(altered(fresh.binding!, actualID: "00000000-0000-0000-0000-000000000002"))), invalid: [M.Stop(.invalidBinding)]) &&
                expectGlobal(replacing(fresh, binding: .some(nil)), invalid: [M.Stop(.invalidBinding)])
        }
        test("16 missing/extra/duplicated operation, exact invalid-plan report") {
            let keys = family.map(\.key)
            return [Array(keys.dropFirst()), keys + [M.Key(type: .piece, logicalID: "not-in-backup")], keys + [keys[0]]].allSatisfy {
                expectGlobal(replacing(fresh, binding: .some(binding($0))), invalid: [M.Stop(.invalidOperationPlan)])
            }
        }
        test("17 completed/unknown operations identify every affected key") {
            expectGlobal(replacing(fresh, binding: .some(binding(family.map(\.key), state: .completed))),
                invalid: family.map { M.Stop(.partialImport, key: $0.key) }) &&
                expectGlobal(replacing(fresh, binding: .some(binding(family.map(\.key), state: .unknownOutcome))),
                    invalid: family.map { M.Stop(.unknownServerOutcome, key: $0.key) })
        }
        test("18 invalid identities, no normalization or fallback") {
            ["", " T-1", "T-1 ", "T\n1", "T-ø"].allSatisfy { id in
                let bad = identity(.textile, id, id)
                return expectGlobal(input([bad]), invalid: [M.Stop(.invalidIdentity, key: bad.key)])
            }
        }
        test("19 too-long candidate, exact stopInvalidBasis") {
            let long = identity(.textile, String(repeating: "T", count: 150), String(repeating: "T", count: 150))
            return expect(input([long]), [long.key: .stopInvalidBasis([M.Stop(.candidateNameTooLong, key: long.key)])])
        }
        test("20 no completion: existing parent reused, every missing child stopped") {
            var expected: Decisions = [parent.key: .reuseExisting(liveFamily[0])]
            for child in family.dropFirst() { expected[child.key] = .stopConflict([M.Stop(.existingTextileCompletion, key: child.key)]) }
            return expect(input(family, [liveFamily[0]]), expected)
        }
        test("21 observed identities absent from inventory: all addresses reported") {
            expectGlobal(replacing(stable, inventory: []), invalid: [M.Stop(.inconsistentInventory)] +
                liveFamily.map { M.Stop(.inconsistentInventory, key: $0.identity.key, address: $0.address) })
        }
        test("22 duplicate address and invalid record name") {
            let r = inventory(liveFamily[0])
            let bad = observed(parent, "")
            return expectGlobal(input(family, liveFamily, extra: [r]), invalid: [M.Stop(.invalidVersions)],
                conflicts: [M.Stop(.duplicateRecordAddress, address: r.address)]) &&
                expectGlobal(input([parent], [bad]), invalid: [M.Stop(.invalidRecordName, address: bad.address), M.Stop(.invalidVersions, address: bad.address)])
        }
        test("23 exact deterministic conflicts for multiple simultaneous faults") {
            let broken = input(family + family, liveFamily + liveFamily)
            let conflicts = family.flatMap { [M.Stop(.duplicateBackupID, key: $0.key), M.Stop(.duplicateObservedID, key: $0.key)] } +
                liveFamily.map { M.Stop(.duplicateRecordAddress, address: $0.address) }
            let invalid = [M.Stop(.invalidVersions)]
            return expectGlobal(broken, invalid: invalid, conflicts: conflicts) &&
                expectGlobal(reordered(broken), invalid: invalid, conflicts: conflicts) && M.evaluate(broken) == M.evaluate(reordered(broken))
        }
        test("24 immutable inputs and exact successes never authorize writing") {
            let original = fresh
            return expect(fresh, newDecisions) && expect(stable, oldDecisions) && fresh == original
        }
        test("25 unrelated synthetic historical orphan stays outside all decisions") {
            let orphan = observed(identity(.image, "IMG-historical", "T0001"), "historical-name")
            return expect(input(family, [orphan]), newDecisions)
        }
        test("26 identical logical IDs across types retain every distinct key") {
            let values = [parent] + M.RecordType.allCases.filter { $0 != .textile }.map { identity($0, "shared-ID", "T-1") }
            return expect(input(values), candidates(values))
        }
        test("27 unexplained inventory entry overrides claimed complete coverage") {
            let r = M.InventoryRecord(type: .textile, address: M.Address(scope: scope, recordName: "unexplained-existing"))
            return expectGlobal(input(family, extra: [r]), invalid: [M.Stop(.unexplainedInventoryRecord, address: r.address)])
        }
        test("28 complete flags cannot conceal an omitted identity from a previously valid snapshot") {
            let r = inventory(liveFamily[0])
            return expectGlobal(input(family, Array(liveFamily.dropFirst()), extra: [r]),
                invalid: [M.Stop(.unexplainedInventoryRecord, address: r.address)])
        }
        test("29 stopped long-name parent stops each dependent child") {
            let id = String(repeating: "T", count: 150)
            let root = identity(.textile, id, id)
            let children = family.dropFirst().map { identity($0.key.type, $0.key.logicalID, id) }
            var expected: Decisions = [root.key: .stopInvalidBasis([M.Stop(.candidateNameTooLong, key: root.key)])]
            for child in children { expected[child.key] = .stopConflict([M.Stop(.parentStopped, key: root.key)]) }
            return expect(input([root] + children), expected)
        }
        test("30 same name collides only in the same full zone/account context") {
            let address = M.Address(scope: scope, recordName: "same-name")
            let records = [M.InventoryRecord(type: .piece, address: address)]
            return M.nameConflicts(proposed: address, inventory: records) &&
                !M.nameConflicts(proposed: M.Address(scope: otherScope(zone: "other-zone"), recordName: address.recordName), inventory: records) &&
                !M.nameConflicts(proposed: M.Address(scope: otherScope(account: "other-account"), recordName: address.recordName), inventory: records)
        }
        test("31 wrong observation/inventory/version scope is rejected") {
            [otherScope(zone: "other-zone"), otherScope(account: "other-account")].allSatisfy { context in
                let wrong = observed(parent, "existing", in: context)
                return expectGlobal(input([parent], [wrong]), invalid: [M.Stop(.invalidScope, address: wrong.address), M.Stop(.invalidVersions, address: wrong.address)])
            }
        }
        test("32 each binding hash and journal-ID comparison tested independently") {
            let b = fresh.binding!, otherHash = String(repeating: "b", count: 64)
            let otherID = "00000000-0000-0000-0000-000000000002"
            return [altered(b, selected: otherHash), altered(b, journalHash: otherHash), altered(b, baselineHash: otherHash),
                altered(b, expectedID: otherID), altered(b, actualID: otherID), altered(b, baselineID: otherID)].allSatisfy {
                expectGlobal(replacing(fresh, binding: .some($0)), invalid: [M.Stop(.invalidBinding)])
            }
        }
        test("33 mixed planned/completed/unknown operations retain exact fault keys") {
            let keys = family.map(\.key)
            let ops = keys.enumerated().map { M.Operation(key: $0.element, state: $0.offset == 1 ? .completed : $0.offset == 2 ? .unknownOutcome : .planned) }
            return expectGlobal(replacing(fresh, binding: .some(altered(fresh.binding!, operations: ops))),
                invalid: [M.Stop(.partialImport, key: keys[1]), M.Stop(.unknownServerOutcome, key: keys[2])])
        }
        test("34 PoC spelling with the wrong type is not an approved filtering exception") {
            pocPairs.allSatisfy { type, name in
                let wrongType: M.RecordType = type == .piece ? .textile : .piece
                let r = M.InventoryRecord(type: wrongType, address: M.Address(scope: scope, recordName: name))
                return expectGlobal(input(family, extra: [r]), invalid: [M.Stop(.unexplainedInventoryRecord, address: r.address)])
            }
        }
        test("35 fully observed PoC-named records remain occupied without unresolved-identity assumption") {
            let live = pocPairs.enumerated().map { index, pair in
                observed(identity(pair.0, "PoC-\(index)", pair.0 == .textile ? "PoC-\(index)" : "PoC-0"), pair.1)
            }
            return expect(input(family, live), newDecisions) && live.allSatisfy {
                M.nameConflicts(proposed: $0.address, inventory: live.map(inventory))
            }
        }
        test("36 assertion rejects empty, missing, extra and duplicate decision rows") {
            let valid = M.evaluate(fresh)
            let wrongKey = M.Key(type: .textile, logicalID: "unexpected")
            let reports = [M.Report(rows: [], globalStops: []), M.Report(rows: Array(valid.rows.dropFirst()), globalStops: []),
                M.Report(rows: valid.rows + [M.Row(key: wrongKey, decision: .stopConflict([]))], globalStops: []),
                M.Report(rows: valid.rows + [valid.rows[0]], globalStops: [])]
            return reports.allSatisfy { !matches($0, input: fresh, decisions: newDecisions) }
        }
        test("37 assertion rejects wrong variant and misplaced/extra conflict reasons") {
            let child = family[1], address = liveFamily[1].address
            let stop = M.Stop(.ownerConflict, key: child.key, address: address)
            let expected: Decisions = [parent.key: .reuseExisting(liveFamily[0]), child.key: .stopConflict([stop])]
            let fixture = input([parent, child], [liveFamily[0], liveFamily[1]])
            let cases: [Decisions] = [
                [parent.key: .reuseExisting(liveFamily[0]), child.key: .stopInvalidBasis([stop])],
                [parent.key: .stopConflict([stop]), child.key: .reuseExisting(liveFamily[1])],
                [parent.key: .reuseExisting(liveFamily[0]), child.key: .stopConflict([M.Stop(.ownerConflict, key: parent.key, address: address)])],
                [parent.key: .reuseExisting(liveFamily[0]), child.key: .stopConflict([stop, M.Stop(.missingParent, key: parent.key)])]]
            return cases.allSatisfy { decisions in
                let report = M.Report(rows: decisions.keys.sorted().map { M.Row(key: $0, decision: decisions[$0]!) }, globalStops: [])
                return !matches(report, input: fixture, decisions: expected)
            }
        }
        test("38 unexplained and filtered inventory stops have deterministic complete ordering") {
            let records = pocPairs.map { M.InventoryRecord(type: $0.0, address: M.Address(scope: scope, recordName: $0.1)) } +
                [M.InventoryRecord(type: .color, address: M.Address(scope: scope, recordName: "unexplained"))]
            let value = input(family, extra: records)
            let reasons = records.dropLast().map { M.Stop(.unresolvedFilteredIdentity, address: $0.address) } +
                [M.Stop(.unexplainedInventoryRecord, address: records.last!.address)]
            return expectGlobal(value, invalid: reasons) && expectGlobal(reordered(value), invalid: reasons) &&
                M.evaluate(value) == M.evaluate(reordered(value))
        }
        print("RESULT \(passed) passed; \(failed) failed. Synthetic classification only; test 239 remains unvalidated by user.")
        if failed > 0 { exit(1) }
    }
}
