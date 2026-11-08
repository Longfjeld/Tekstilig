import Darwin
import Foundation

@main @MainActor
struct DevelopmentTextileRelationshipDiagnosticTests {
    typealias P = DevelopmentTextileRelationshipDiagnostic
    typealias D = ImportIdentityReadDiagnostic
    typealias E = CloudKitEnvironmentVerification
    typealias S = DevelopmentIdentityReadSession
    typealias M = ImportIdentityDecisionModel
    static let scope = M.Scope(container: "fixture-container", environment: "Development", account: "fixture-account",
        database: "private", zone: "fixture-zone", zoneOwner: "fixture-owner")
    static var family: [D.Observation] {
        M.RecordType.allCases.map { record($0.rawValue, $0 == .textile ? "T-1" : "ID-" + $0.rawValue, "T-1", "random-" + $0.rawValue) }
    }
    static var observations: [D.Observation] {
        family + [record("Textile", "T-POC", "T-POC", "swiftui-poc-textile-v1"),
            record("Piece", "P-POC", "T-POC", "swiftui-poc-piece-v1"),
            record("TextileImage", "I-POC", "T-POC", "swiftui-poc-textile-image-v1"),
            record("TextileImage", "IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC", "T0001", "74B85BA7-9EBF-48FD-A04A-828329F9B237")]
    }
    static func record(_ type: String, _ id: String, _ owner: String, _ name: String) -> D.Observation {
        .init(recordType: type, logicalID: .string(id), owner: .string(owner), recordName: name,
            zone: scope.zone, zoneOwner: scope.zoneOwner, changeTag: "tag")
    }
    static func result(_ values: [D.Observation]? = nil, issues: [String] = [], complete: Bool = true) -> D.ReadResult {
        .init(context: .init(scope: scope, environmentSource: .signedApplicationEntitlement, expectedEnvironment: .development),
            first: values ?? observations, second: values ?? observations,
            firstTypes: complete ? Set(M.RecordType.allCases) : [], secondTypes: complete ? Set(M.RecordType.allCases) : [], issues: issues)
    }
    static func presentation(_ result: D.ReadResult?, issues: [String] = [], running: Bool = false, cancelled: Bool = false) -> P.Presentation {
        P.make(result: result, environment: .verified(.development), issues: issues, isRunning: running, cancellationRequested: cancelled)
    }
    final class Evidence: CloudKitEnvironmentEvidenceSource {
        var supported = true
        var value = E.Entitlement.string("Development")
        var calls = 0
        func copySelf() -> Int32 { calls += 1; return 0 }
        func checkValidity() -> Int32 { calls += 1; return 0 }
        func createTask() -> Bool { calls += 1; return true }
        func entitlement() -> E.Entitlement { calls += 1; return value }
    }
    enum Fault: Error { case page }
    final class Transport: ImportIdentityReadTransport {
        var accounts = 0
        var pages = 0
        var failPage: Int?
        var onPage: (() -> Void)?
        func context() async throws -> D.Context {
            accounts += 1
            return .init(scope: scope, environmentSource: .signedApplicationEntitlement, expectedEnvironment: .development)
        }
        func page(type: M.RecordType, after cursor: String?) async throws -> D.Page {
            pages += 1
            if pages == failPage { throw Fault.page }
            onPage?()
            return .init(observations: observations.filter { $0.recordType == type.rawValue }, recordErrors: [], nextCursor: nil)
        }
    }
    @MainActor final class Fixture {
        let evidence = Evidence()
        let transport = Transport()
        var factories = 0
        var expected: [E.Environment] = []
        func session() -> S {
            S(makeSource: { self.evidence }, makeTransport: { expectation in
                self.factories += 1; self.expected.append(expectation); return self.transport
            })
        }
    }
    static func snapshot(_ session: S) -> P.Presentation {
        P.make(result: session.result, environment: session.environment, issues: session.issues,
            isRunning: session.isRunning, cancellationRequested: session.cancellationRequested)
    }
    static func main() async {
        var count = 0
        @MainActor func check(_ name: String, _ body: () async -> Bool) async {
            guard await body() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        await check("01 isolated session construction and repeated presentation never start work") {
            let f = Fixture(), before = 0; let s = f.session()
            let p = snapshot(s); _ = snapshot(s); s.cancel(); await Task.yield()
            return f.evidence.calls == before && f.factories == 0 && f.transport.accounts == 0 && f.transport.pages == 0 &&
                p.adapted == nil && !p.readComplete && p.hasStop && !p.permitsCloudKitWriting && !s.isRunning
        }
        await check("02 explicit B.3 start locks Development and preserves exact nine-record passes") {
            let f = Fixture(); let s = f.session(); await s.start()?.value
            let p = snapshot(s)
            guard let a = p.adapted else { return false }
            let expectedNames = observations.filter { $0.recordType != "Textile" }.map(\.recordName).sorted()
            return f.factories == 1 && f.expected == [.development] && f.transport.accounts == 3 && f.transport.pages == 10 &&
                p.readComplete && p.hasStop && a.first.rows.count == 7 && a.second.rows.count == 7 &&
                a.first.rows.map { $0.observation.child.recordName }.sorted() == expectedNames &&
                a.first.basis == a.second.basis && a.first.basis.parents.count == 2 &&
                p.text.contains("Pass 1: 9 råobservasjoner; 7 underpostrader") && p.text.contains("Pass 2: 9 råobservasjoner; 7 underpostrader")
        }
        await check("03 all four child types, PoC and T0001 have exact outcomes in both passes") {
            let p = presentation(result())
            guard let a = p.adapted else { return false }
            return [a.first, a.second].allSatisfy { report in
                report.rows.count == 7 && Set(report.rows.map { $0.observation.child.type.rawValue }) == Set(["Piece", "TextileMaterial", "TextileColor", "TextileImage"]) &&
                report.rows.allSatisfy { row in
                    row.observation.child.owner == .string("T0001")
                        ? row.observation.outcome == .parentNotObservedWithCompleteCoverage && row.explanation.contains("beviser ikke historisk sletting")
                        : row.observation.outcome == .uniqueObservedParent
                } && report.rows.filter { $0.observation.child.recordName.contains("swiftui-poc-") }.count == 2
            } && p.text.contains("T0001") && p.text.contains("swiftui-poc-textile-v1") && !p.permitsCloudKitWriting
        }
        await check("04 complete reads and relation STOPP are distinct, never write approval") {
            let missing = presentation(result()), unique = presentation(result(family))
            return missing.readComplete && missing.hasStop && missing.text.contains("Lesing: KOMPLETT") && missing.text.contains("Relasjonsvurdering: STOPP") &&
                unique.readComplete && !unique.hasStop && unique.text.contains("Relasjonsvurdering: OBSERVERT") && !unique.permitsCloudKitWriting
        }
        await check("05 duplicate reader failures retained and completeness blocked") {
            let r = result(issues: ["page-error", "page-error"]), p = presentation(r)
            return !p.readComplete && p.hasStop && p.source?.issues == r.issues && p.adapted?.issues == r.issues &&
                p.adapted?.first.rows.count == 7 && p.text.components(separatedBy: "STOPP: page-error").count == 3
        }
        await check("06 incomplete coverage retains every available child and cannot prove absence") {
            let p = presentation(result(complete: false))
            return !p.readComplete && p.hasStop && p.adapted?.first.rows.count == 7 &&
                p.adapted?.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } == true
        }
        await check("07 Production mismatch prevents transport and fake account lookups") {
            let f = Fixture(); f.evidence.value = .string("Production")
            let s = f.session(); await s.start()?.value; let p = snapshot(s)
            return f.factories == 0 && f.transport.accounts == 0 && f.transport.pages == 0 &&
                s.environment == .mismatch(expected: .development, observed: .production) && p.hasStop && !p.readComplete && p.adapted == nil
        }
        await check("08 missing local proof also blocks a supplied otherwise complete result") {
            let p = P.make(result: result(family), environment: nil, issues: [], isRunning: false, cancellationRequested: false)
            return p.hasStop && !p.readComplete && p.adapted?.first.rows.count == 4 &&
                p.adapted?.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } == true
        }
        await check("09 page failure preserves partial parent observations and incomplete second pass") {
            let f = Fixture(); f.transport.failPage = 2
            let s = f.session(); await s.start()?.value; let p = snapshot(s)
            return f.transport.pages == 2 && !p.readComplete && p.hasStop && p.adapted?.first.basis.parents.count == 2 &&
                p.adapted?.first.rows.isEmpty == true && p.adapted?.second.rows.isEmpty == true && p.text.contains("Lesefeil:")
        }
        await check("10 cancellation before start work makes no evidence/transport calls") {
            let f = Fixture(); let s = f.session(); let task = s.start(); s.cancel(); await task?.value
            let p = snapshot(s)
            return f.evidence.calls == 0 && f.factories == 0 && p.hasStop && !p.readComplete && p.adapted == nil
        }
        await check("11 cancellation during page retains partial raw data without retry") {
            let f = Fixture(); let s = f.session(); f.transport.onPage = { s.cancel() }
            await s.start()?.value; await Task.yield(); let p = snapshot(s)
            return f.transport.pages == 1 && f.transport.accounts == 1 && !p.readComplete && p.hasStop &&
                p.source?.first.count == 2 && p.adapted?.firstInput.coverage[0].textileReadComplete == false && p.text.contains("Lesing avbrutt")
        }
        await check("12 session cancellation/running/errors cannot present complete stored observations") {
            let r = result(family)
            let values = [presentation(r, cancelled: true), presentation(r, running: true), presentation(r, issues: ["session-error"])]
            return values.allSatisfy { !$0.readComplete && $0.hasStop && $0.adapted?.first.rows.count == 4 &&
                $0.adapted?.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } == true && !$0.permitsCloudKitWriting }
        }
        await check("13 parallel start rejected; presentation never triggers another read") {
            let f = Fixture(); let s = f.session(); let task = s.start()
            guard s.start() == nil else { return false }
            await task?.value; _ = snapshot(s); _ = snapshot(s); await Task.yield()
            return f.factories == 1 && f.transport.pages == 10 && !s.isRunning
        }
        await check("14 deterministic text, raw duplicate observations, errors and scopes retained") {
            let raw = D.Observation(recordType: "Unknown", logicalID: .string(" raw ID\n"), owner: .nonString(type: "Int", description: "7"),
                recordName: "raw-name", zone: "other-zone", zoneOwner: "other-owner", changeTag: nil)
            let values = observations + [raw, raw]
            let a = presentation(result(values, issues: ["b", "a", "a"])), b = presentation(result(Array(values.reversed()), issues: ["a", "b", "a"]))
            return a.text == b.text && a.hasStop && !a.readComplete && a.source?.first == values &&
                a.text.contains("other-zone") && a.text.contains("other-owner") && a.text.contains("nonString") &&
                a.text.components(separatedBy: "Pass 1 RÅ | \"Unknown\"").count == 3 && a.adapted?.first.rows.count == 7
        }
        await check("15 missing record context never gains coverage; no baseline/import proof") {
            let r = result()
            let missing = D.ReadResult(context: nil, first: r.first, second: r.second, firstTypes: r.firstTypes, secondTypes: r.secondTypes, issues: [])
            let p = presentation(missing)
            return p.source?.context == nil && p.adapted?.firstInput.coverage.isEmpty == true && !p.readComplete && p.hasStop &&
                p.text.contains("Ingen historisk baseline-") && p.text.contains("Ingen importbeslutning") && !p.permitsCloudKitWriting
        }
        await check("16 supplied Production context is never accepted by Development presentation") {
            let r = result(family)
            let c = D.Context(scope: .init(container: scope.container, environment: "Production", account: scope.account,
                database: scope.database, zone: scope.zone, zoneOwner: scope.zoneOwner),
                environmentSource: .signedApplicationEntitlement, expectedEnvironment: .production)
            let wrong = D.ReadResult(context: c, first: r.first, second: r.second, firstTypes: r.firstTypes, secondTypes: r.secondTypes, issues: [])
            let p = presentation(wrong)
            return p.hasStop && !p.readComplete && p.source?.context == c && p.adapted?.first.rows.count == 4 &&
                p.adapted?.first.rows.allSatisfy { $0.observation.outcome == .incompleteCoverage } == true
        }
        print("\(count) PASS, 0 FAIL — fake B.3 session and in-memory relationship presentation only.")
    }
}
