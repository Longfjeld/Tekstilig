import Foundation
import CloudKit
import Darwin

@main @MainActor
struct ImportIdentityReadDiagnosticTests {
    typealias D = ImportIdentityReadDiagnostic
    typealias M = ImportIdentityDecisionModel
    typealias A = ImportIdentityDiagnosticAdapter
    static let scope = M.Scope(container: "synthetic", environment: "Development", account: "fixture-account",
        database: "private", zone: "fixture-zone", zoneOwner: "fixture-owner")
    // Claimed evidence here is synthetic. No test obtains actual signing/account information.
    static let context = D.Context(scope: scope, environmentSource: .signedApplicationEntitlement)
    static let hash = String(repeating: "a", count: 64)
    static let journalID = "00000000-0000-0000-0000-000000000001"
    static let family = M.RecordType.allCases.enumerated().map { index, type in
        D.Observation(recordType: type.rawValue, logicalID: .string(type == .textile ? "T-1" : "ID-\(type.rawValue)"),
            owner: .string("T-1"), recordName: "random-\(index)", zone: scope.zone, zoneOwner: scope.zoneOwner, changeTag: "tag-1")
    }
    static let poc = [(M.RecordType.textile, "swiftui-poc-textile-v1"), (.piece, "swiftui-poc-piece-v1"), (.image, "swiftui-poc-textile-image-v1")].map {
        D.Observation(recordType: $0.0.rawValue, logicalID: .string($0.0 == .textile ? "T-POC" : "POC-\($0.0.rawValue)"),
            owner: .string("T-POC"), recordName: $0.1, zone: scope.zone, zoneOwner: scope.zoneOwner, changeTag: "poc-tag")
    }
    static var all: [D.Observation] { family + poc }
    static func sorted(_ values: [D.Observation]) -> [D.Observation] {
        values.sorted { $0.order.lexicographicallyPrecedes($1.order) }
    }
    static func changed(_ value: D.Observation, id: D.RawField? = nil, owner: D.RawField? = nil,
                        name: String? = nil, zone: String? = nil, zoneOwner: String? = nil,
                        tag: String?? = nil, type: String? = nil) -> D.Observation {
        D.Observation(recordType: type ?? value.recordType, logicalID: id ?? value.logicalID, owner: owner ?? value.owner,
            recordName: name ?? value.recordName, zone: zone ?? value.zone, zoneOwner: zoneOwner ?? value.zoneOwner,
            changeTag: tag ?? value.changeTag)
    }
    enum SyntheticError: Error { case page, context }
    final class Fake: ImportIdentityReadTransport {
        var contexts = [ImportIdentityReadDiagnosticTests.context]
        var contextCount = 0
        var calls: [(M.RecordType, String?)] = []
        var pass = 0
        var rows = [ImportIdentityReadDiagnosticTests.all, ImportIdentityReadDiagnosticTests.all]
        var paginate = false
        var failPage: Int?
        var failContext: Int?
        var recordError: Int?
        var repeatCursor = false
        var cancelOnPage = false
        func context() async throws -> D.Context {
            contextCount += 1
            if contextCount == failContext { throw SyntheticError.context }
            return contexts[min(contextCount - 1, contexts.count - 1)]
        }
        func page(type: M.RecordType, after cursor: String?) async throws -> D.Page {
            calls.append((type, cursor))
            if calls.count == failPage { throw SyntheticError.page }
            let values = rows[min(pass, rows.count - 1)].filter { $0.recordType == type.rawValue || $0.recordType == "Unexpected" }
            let split = paginate && values.count > 1
            let next: String? = repeatCursor ? "loop" : (split && cursor == nil ? "next" : nil)
            let selected = split ? (cursor == nil ? Array(values.prefix(1)) : Array(values.dropFirst())) : values
            if type == .image && next == nil { pass += 1 }
            if cancelOnPage { withUnsafeCurrentTask { $0?.cancel() } }
            return D.Page(observations: selected, recordErrors: calls.count == recordError ? ["synthetic-record-error"] : [], nextCursor: next)
        }
    }
    static func source(legacy: Bool = false) -> A.Snapshot {
        A.Snapshot(scope: nil, backup: family.map { .init(type: $0.recordType, logicalID: $0.logicalID.string!, owner: $0.owner.string!) },
            observed: [], current: nil,
            baseline: .init(schemaVersion: 1, journalID: journalID, zipSHA256: hash, entries: all.map {
                .init(type: $0.recordType, recordName: $0.recordName, changeTag: $0.changeTag!, scope: legacy ? nil : scope)
            }), journal: .init(schemaVersion: 2, journalID: journalID, state: "planned-read-only", operationIDs: [],
                completedOperationCount: 0, zipSHA256: hash), selectedZIPHash: hash,
            coverage: .init(verifiedIdentityTypes: [], completeNameInventory: false, completeVersions: false, readErrors: []),
            rawIdentitiesVerified: false)
    }
    static func globalReport(_ report: M.Report, reasons: [M.Stop]) -> Bool {
        let reasons = Array(Set(reasons)).sorted()
        let keys = family.map { M.Key(type: M.RecordType(rawValue: $0.recordType)!, logicalID: $0.logicalID.string!) }.sorted()
        return report == M.Report(rows: keys.map { .init(key: $0, decision: .stopInvalidBasis(reasons)) }, globalStops: reasons) &&
            !report.permitsCloudKitWriting
    }
    static func main() async {
        var count = 0
        func check(_ name: String, _ body: () async -> Bool) async {
            guard await body() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        await check("01 all five types and three PoC observations, exact two passes") {
            let fake = Fake(); let result = await D.read(using: fake)
            return result.context == context && result.issues.isEmpty && result.first == sorted(all) && result.second == sorted(all) &&
                result.firstTypes == Set(M.RecordType.allCases) && result.secondTypes == result.firstTypes && fake.calls.count == 10 && fake.contextCount == 3
        }
        await check("02 paginated reads retain every record and cursor") {
            let fake = Fake(); fake.paginate = true
            let result = await D.read(using: fake)
            return !result.hasStops && result.first == sorted(all) && result.second == sorted(all) &&
                fake.calls.count == 16 && fake.calls.filter { $0.1 == "next" }.count == 6
        }
        await check("03 same CKRecord decoding preserves raw fields, type, address and missing tag") {
            let zone = CKRecordZone.ID(zoneName: "raw-zone", ownerName: "raw-owner")
            for type in M.RecordType.allCases {
                let record = CKRecord(recordType: type.rawValue, recordID: CKRecord.ID(recordName: "raw-name", zoneID: zone))
                record[D.idField(type)] = " ID \n" as CKRecordValue
                if type != .textile { record["textileId"] = " T \t" as CKRecordValue }
                let actual = CloudKitIdentityDiagnosticTransport.observation(record, requestedType: type)
                let expected = D.Observation(recordType: type.rawValue, logicalID: .string(" ID \n"),
                    owner: .string(type == .textile ? " ID \n" : " T \t"), recordName: "raw-name", zone: "raw-zone", zoneOwner: "raw-owner", changeTag: record.recordChangeTag)
                if actual != expected || actual.changeTag != nil { return false }
            }
            return true
        }
        await check("04 absent and non-string fields are distinct observations") {
            let record = CKRecord(recordType: "Piece")
            record["pieceId"] = NSNumber(value: 42)
            let actual = CloudKitIdentityDiagnosticTransport.observation(record, requestedType: .piece)
            guard case .nonString(let type, let value) = actual.logicalID else { return false }
            return !type.isEmpty && value.contains("42") && actual.owner == .missing
        }
        await check("05 minimal desired keys exclude assets and preserve identity fields") {
            return M.RecordType.allCases.allSatisfy { type in
                D.desiredKeys(type) == (type == .textile ? ["textileId"] : [D.idField(type), "textileId"]) &&
                    !D.desiredKeys(type).contains("imageAsset")
            }
        }
        await check("06 invalid raw value retained and stops before next page") {
            let fake = Fake(); let bad = changed(family[0], id: .string(" T-1 "))
            fake.rows = [[bad]]
            let result = await D.read(using: fake)
            return result.first == [bad] && result.issues == ["Ugyldig rå-ID: Textile:\"random-0\""] && fake.calls.count == 1 && result.firstTypes.isEmpty
        }
        await check("07 missing identity/eier and tag stop with exact reasons") {
            let fake = Fake(); let bad = changed(family[0], id: .missing, owner: .missing, tag: .some(nil))
            fake.rows = [[bad]]
            let result = await D.read(using: fake)
            return result.first == [bad] && result.issues == ["Manglende/ugyldig changeTag: Textile:\"random-0\"", "Ugyldig rå-ID: Textile:\"random-0\"", "Ugyldig rå-eier: Textile:\"random-0\""].sorted()
        }
        await check("08 record error retains successful records and stops") {
            let fake = Fake(); fake.recordError = 1
            let result = await D.read(using: fake)
            return result.first == sorted([family[0], poc[0]]) && result.issues == ["Textile postfeil: synthetic-record-error"] && fake.calls.count == 1
        }
        await check("09 page error retains earlier pages, incomplete coverage") {
            let fake = Fake(); fake.failPage = 2
            let result = await D.read(using: fake)
            return result.first == sorted([family[0], poc[0]]) && result.issues == ["Lesefeil: page"] && result.firstTypes == [.textile] && result.secondTypes.isEmpty
        }
        await check("10 cancellation before transport access") {
            let fake = Fake()
            let task = Task { @MainActor in await D.read(using: fake) }; task.cancel()
            let result = await task.value
            return result.issues == ["Lesing avbrutt"] && fake.contextCount == 0 && fake.calls.isEmpty
        }
        await check("11 cancellation during page retains observations") {
            let fake = Fake(); fake.cancelOnPage = true
            let result = await Task { @MainActor in await D.read(using: fake) }.value
            return result.issues == ["Lesing avbrutt"] && result.first == sorted([family[0], poc[0]]) && fake.calls.count == 1
        }
        await check("12 repeated cursor stops without infinite loop or discarding duplicates") {
            let fake = Fake(); fake.repeatCursor = true
            let result = await D.read(using: fake)
            return result.issues == ["Ugyldig/gjentatt cursor: Textile"] && result.first.count == 4 && fake.calls.count == 2
        }
        await check("13 duplicate logical identities with distinct names retained") {
            let fake = Fake(); fake.rows[0].append(changed(family[1], name: "another-name"))
            let result = await D.read(using: fake)
            return result.issues == ["Duplisert logisk identitet: \"Piece\":\"ID-Piece\""] && result.first.count == 9 && result.second.isEmpty
        }
        await check("14 physical name collision across record types") {
            let fake = Fake(); fake.rows[0][1] = changed(family[1], name: family[0].recordName)
            let result = await D.read(using: fake)
            return result.issues == ["Duplisert recordadresse: \"random-0\""] && result.first.count == 8
        }
        await check("15 unverified environment never falls back to DEBUG/development") {
            let fake = Fake(); fake.contexts = [.init(scope: scope, environmentSource: .unverified)]
            let result = await D.read(using: fake)
            return result.issues == ["Uverifisert/ugyldig CloudKit-kontekst"] && fake.calls.isEmpty
        }
        await check("16 each required scope component validated") {
            let fields = [scope.container, scope.environment, scope.account, scope.database, scope.zone, scope.zoneOwner]
            for index in fields.indices {
                var f = fields; f[index] = ""
                let c = D.Context(scope: .init(container: f[0], environment: f[1], account: f[2], database: f[3], zone: f[4], zoneOwner: f[5]), environmentSource: .signedApplicationEntitlement)
                let fake = Fake(); fake.contexts = [c]
                let result = await D.read(using: fake)
                if result.issues != ["Uverifisert/ugyldig CloudKit-kontekst"] || !fake.calls.isEmpty { return false }
            }
            return true
        }
        await check("17 wrong zone and zone owner retained, no scope substitution") {
            let fake = Fake(); let bad = changed(family[0], zone: "other-zone", zoneOwner: "other-owner")
            fake.rows = [[bad]]
            let result = await D.read(using: fake)
            let mapped = result.applying(to: source())
            return result.first == [bad] && result.issues == ["Feil recordkontekst: Textile:\"random-0\""] &&
                mapped.observed[0].scope?.zone == "other-zone" && mapped.observed[0].scope?.zoneOwner == "other-owner"
        }
        await check("18 account change between passes stops before pass two") {
            let fake = Fake(); fake.contexts = [context, .init(scope: .init(container: scope.container,
                environment: scope.environment, account: "other-account", database: scope.database, zone: scope.zone, zoneOwner: scope.zoneOwner), environmentSource: .signedApplicationEntitlement)]
            let result = await D.read(using: fake)
            return result.issues == ["CloudKit-kontekst/konto endret under lesing"] && result.first.count == 8 && result.second.isEmpty
        }
        await check("19 final context read failure prevents completeness") {
            let fake = Fake(); fake.failContext = 3
            let result = await D.read(using: fake)
            return result.issues == ["Lesefeil: context"] && !result.applying(to: source()).coverage.completeVersions
        }
        await check("20 changed ID/eier/tag/addition/deletion between passes stops") {
            let variants = [all.dropLast().map { $0 }, all + [changed(family[0], id: .string("T-extra"), owner: .string("T-extra"), name: "extra")],
                [changed(family[0], tag: .some("new-tag"))] + Array(all.dropFirst()),
                [changed(family[0], id: .string("T-other"))] + Array(all.dropFirst()),
                [changed(family[0], owner: .string("T-other"))] + Array(all.dropFirst())]
            for variant in variants {
                let fake = Fake(); fake.rows[1] = variant
                let result = await D.read(using: fake)
                if result.issues != ["Observasjoner endret mellom passeringer"] || result.second != sorted(variant) { return false }
            }
            return true
        }
        await check("21 reordered pages produce identical complete result") {
            let fake = Fake(); fake.rows[1].reverse()
            let result = await D.read(using: fake)
            return result.issues.isEmpty && result.first == sorted(all) && result.second == result.first
        }
        await check("22 complete adapter bridge gives exact five reuse decisions and preserves source") {
            let original = source(); let before = original
            let result = await D.read(using: Fake())
            let mapped = result.applying(to: original)
            let report = M.evaluate(A.adapt(mapped).input)
            let expected = M.Report(rows: family.map { value in
                let key = M.Key(type: M.RecordType(rawValue: value.recordType)!, logicalID: value.logicalID.string!)
                return M.Row(key: key, decision: .reuseExisting(.init(identity: .init(key: key, owner: value.owner.string!),
                    address: .init(scope: scope, recordName: value.recordName))))
            }.sorted { $0.key < $1.key }, globalStops: [])
            return original == before && mapped.observed.count == 8 && mapped.current?.count == 8 && report == expected && !report.permitsCloudKitWriting
        }
        await check("23 legacy baseline never receives inferred current scope") {
            let original = source(legacy: true)
            let result = await D.read(using: Fake()); let mapped = result.applying(to: original)
            let report = M.evaluate(A.adapt(mapped).input)
            let empty = M.Scope(container: "", environment: "", account: "", database: "", zone: "", zoneOwner: "")
            let stops = [M.Stop(.incompleteCoverage), .init(.baselineChanged)] + all.map {
                M.Stop(.invalidVersions, address: .init(scope: empty, recordName: $0.recordName))
            }
            return mapped.baseline == original.baseline && globalReport(report, reasons: stops)
        }
        await check("24 partial reader cannot become a successful adapter report") {
            let fake = Fake(); fake.failPage = 2
            let result = await D.read(using: fake)
            return globalReport(M.evaluate(A.adapt(result.applying(to: source())).input),
                reasons: [.init(.incompleteCoverage), .init(.baselineChanged)])
        }
        await check("25 wrong record type is retained and rejected") {
            let fake = Fake(); let bad = changed(family[0], type: "Unexpected"); fake.rows = [[bad]]
            let result = await D.read(using: fake)
            return result.first == [bad] && result.issues == ["Feil posttype: Unexpected:\"random-0\""]
        }
        await check("26 report shows context/raw evidence and denies atomism and writes") {
            let result = await D.read(using: Fake())
            let text = result.render(using: source())
            return text.contains("fixture-account") && text.contains("signedApplicationEntitlement") &&
                text.contains("swiftui-poc-textile-image-v1") && text.contains("CloudKit-skriving: false") &&
                text.contains("Ingen atomisk snapshot")
        }
        print("\(count) PASS, 0 FAIL – synthetic transport only; test 241 remains unvalidated.")
    }
}
