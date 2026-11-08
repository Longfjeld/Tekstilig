import Foundation
import Darwin

@main @MainActor
struct DevelopmentIdentityReadSessionTests {
    typealias S = DevelopmentIdentityReadSession
    typealias D = ImportIdentityReadDiagnostic
    typealias E = CloudKitEnvironmentVerification
    typealias M = ImportIdentityDecisionModel
    static let scope = M.Scope(container: "synthetic", environment: "Development", account: "fake-account",
        database: "private", zone: "fake-zone", zoneOwner: "fake-owner")
    static let rows = M.RecordType.allCases.map { type in
        D.Observation(recordType: type.rawValue, logicalID: .string("ID-\(type.rawValue)"), owner: .string("ID-Textile"),
            recordName: "random-\(type.rawValue)", zone: scope.zone, zoneOwner: scope.zoneOwner, changeTag: "tag-1")
    }
    final class Evidence: CloudKitEnvironmentEvidenceSource {
        var supported = true
        var code: Int32 = 0
        var signature: Int32 = 0
        var taskAvailable = true
        var value: E.Entitlement = .string("Development")
        var calls = 0
        func copySelf() -> Int32 { calls += 1; return code }
        func checkValidity() -> Int32 { calls += 1; return signature }
        func createTask() -> Bool { calls += 1; return taskAvailable }
        func entitlement() -> E.Entitlement { calls += 1; return value }
    }
    enum Fault: Error { case page }
    final class Transport: ImportIdentityReadTransport {
        let evidence = Evidence()
        var expected: E.Environment = .development
        var accountCalls = 0
        var pageCalls = 0
        var failPage: Int?
        var recordError = false
        var onPage: (() -> Void)?
        func context() async throws -> D.Context {
            try await E.withVerifiedEnvironment(source: evidence, expected: expected) { environment in
                accountCalls += 1
                return D.Context(scope: .init(container: scope.container, environment: environment.rawValue,
                    account: scope.account, database: scope.database, zone: scope.zone, zoneOwner: scope.zoneOwner),
                    environmentSource: .signedApplicationEntitlement, expectedEnvironment: expected)
            }
        }
        func page(type: M.RecordType, after cursor: String?) async throws -> D.Page {
            pageCalls += 1
            if failPage == pageCalls { throw Fault.page }
            onPage?()
            return D.Page(observations: rows.filter { $0.recordType == type.rawValue },
                recordErrors: recordError ? ["fake-record-error"] : [], nextCursor: nil)
        }
    }
    @MainActor final class Fixture {
        let evidence = Evidence()
        let transport = Transport()
        var sources = 0
        var factories = 0
        var expectations: [E.Environment] = []
        func session() -> S {
            S(makeSource: { self.sources += 1; return self.evidence }, makeTransport: { expected in
                self.factories += 1; self.expectations.append(expected)
                self.transport.expected = expected
                return self.transport
            })
        }
    }
    static func main() async {
        var count = 0
        func check(_ name: String, _ body: () async -> Bool) async {
            guard await body() else { print("FAIL \(name)"); exit(1) }
            count += 1; print("PASS \(name)")
        }
        await check("01 initialization/report/idle cancellation perform no work") {
            let f = Fixture(); let s = f.session(); s.cancel()
            _ = s.report
            await Task.yield()
            return !s.isRunning && !s.cancellationRequested && s.result == nil && s.environment == nil &&
                s.issues.isEmpty && f.sources == 0 && f.factories == 0 && f.evidence.calls == 0 &&
                f.transport.accountCalls == 0 && f.transport.pageCalls == 0
        }
        await check("02 explicit start locks Development and reads exact two five-type passes") {
            let f = Fixture(); let s = f.session(); await s.start()?.value
            let sorted = rows.sorted { $0.order.lexicographicallyPrecedes($1.order) }
            guard let result = s.result else { return false }
            return !s.isRunning && s.issues.isEmpty && s.environment == .verified(.development) &&
                !result.hasStops && result.first == sorted && result.second == sorted &&
                result.firstTypes == Set(M.RecordType.allCases) && result.secondTypes == result.firstTypes &&
                f.sources == 1 && f.factories == 1 && f.expectations == [.development] &&
                f.transport.accountCalls == 3 && f.transport.pageCalls == 10 &&
                M.RecordType.allCases.allSatisfy { s.report.contains("Pass 1 antall \($0.rawValue): 1; fullført: true") &&
                    s.report.contains("Pass 2 antall \($0.rawValue): 1; fullført: true") }
        }
        await check("03 Production proof stops before transport creation or account lookup") {
            let f = Fixture(); f.evidence.value = .string("Production")
            let s = f.session(); await s.start()?.value
            return s.environment == .mismatch(expected: .development, observed: .production) && s.result == nil &&
                s.issues.count == 1 && s.report.contains("STOPP:") && f.factories == 0 &&
                f.transport.accountCalls == 0 && f.transport.pageCalls == 0
        }
        await check("04 every local evidence failure blocks transport/account/records") {
            for failure in 0..<8 {
                let f = Fixture()
                switch failure {
                case 0: f.evidence.supported = false
                case 1: f.evidence.code = -1
                case 2: f.evidence.signature = -2
                case 3: f.evidence.taskAvailable = false
                case 4: f.evidence.value = .missing
                case 5: f.evidence.value = .invalidType("Number")
                case 6: f.evidence.value = .string(" Development")
                default: f.evidence.value = .failure("fake-error")
                }
                let s = f.session(); await s.start()?.value
                guard case .unverified = s.environment else { return false }
                if s.issues.count != 1 || s.result != nil || f.factories != 0 ||
                    f.transport.accountCalls != 0 || f.transport.pageCalls != 0 { return false }
            }
            return true
        }
        await check("05 transport repeats environment gate before fake account lookup") {
            let f = Fixture(); f.transport.evidence.value = .string("Production")
            let s = f.session(); await s.start()?.value
            return s.environment == .verified(.development) && f.factories == 1 && f.transport.accountCalls == 0 &&
                f.transport.pageCalls == 0 && s.result?.hasStops == true && s.result?.context == nil &&
                s.result?.first.isEmpty == true && s.report.contains("mismatch")
        }
        await check("06 page failure retains exact partial observations and incomplete coverage") {
            let f = Fixture(); f.transport.failPage = 2
            let s = f.session(); await s.start()?.value
            guard let r = s.result else { return false }
            return r.first == [rows[0]] && r.second.isEmpty && r.firstTypes == [.textile] && r.secondTypes.isEmpty &&
                r.issues.count == 1 && r.issues[0].contains("Lesefeil:") && f.transport.pageCalls == 2 &&
                s.report.contains("Pass 1 antall Textile: 1; fullført: true") &&
                s.report.contains("Pass 1 antall Piece: 0; fullført: false") && s.report.contains("STOPP")
        }
        await check("07 record error retains successful row without completed type") {
            let f = Fixture(); f.transport.recordError = true
            let s = f.session(); await s.start()?.value
            guard let r = s.result else { return false }
            return r.first == [rows[0]] && r.second.isEmpty && r.firstTypes.isEmpty && r.secondTypes.isEmpty &&
                r.issues == ["Textile postfeil: fake-record-error"] && f.transport.pageCalls == 1
        }
        await check("08 immediate cancellation prevents evidence and factory calls") {
            let f = Fixture(); let s = f.session(); let work = s.start(); s.cancel(); await work?.value
            return !s.isRunning && s.cancellationRequested && s.result == nil && s.environment == nil &&
                s.issues == ["Lesing avbrutt før miljøkontroll"] && f.sources == 0 && f.factories == 0
        }
        await check("09 cancellation during page retains row and stops without retry") {
            let f = Fixture(); let s = f.session(); f.transport.onPage = { s.cancel() }
            await s.start()?.value
            guard let r = s.result else { return false }
            return !s.isRunning && s.cancellationRequested && s.issues == ["Lesing avbrutt"] &&
                r.first == [rows[0]] && r.second.isEmpty && r.firstTypes.isEmpty &&
                r.issues == ["Lesing avbrutt"] && f.transport.accountCalls == 1 && f.transport.pageCalls == 1
        }
        await check("10 concurrent start rejected; repeat requires another explicit start") {
            let f = Fixture(); let s = f.session(); let first = s.start()
            guard s.isRunning && s.start() == nil else { return false }
            await first?.value; await Task.yield(); await Task.yield()
            guard f.factories == 1 && f.transport.pageCalls == 10 else { return false }
            await s.start()?.value
            return !s.isRunning && f.factories == 2 && f.sources == 2 && f.transport.pageCalls == 20
        }
        await check("11 standalone report preserves malformed raw fields and deterministic ordering") {
            let invalid = D.Observation(recordType: "Unexpected", logicalID: .string(" raw ID "),
                owner: .nonString(type: "Number", description: "42"), recordName: "raw-name", zone: "wrong-zone", zoneOwner: "owner", changeTag: nil)
            let context = D.Context(scope: scope, environmentSource: .signedApplicationEntitlement, expectedEnvironment: .development)
            @MainActor func report(_ values: [D.Observation]) -> String {
                S.render(result: .init(context: context, first: values, second: [], firstTypes: [], secondTypes: [], issues: ["fake-stop"]),
                    environment: .verified(.development), issues: [])
            }
            let text = report(rows + [invalid])
            return text == report(Array((rows + [invalid]).reversed())) && text.contains(" raw ID ") &&
                text.contains("nonString") && text.contains("42") && text.contains("changeTag nil") &&
                text.contains("Unexpected") && text.contains("STOPP: fake-stop") && text.contains("Ingen atomisk snapshot") &&
                text.contains("Konto (CloudKit-recordName): \"fake-account\"")
        }
        print("\(count) PASS, 0 FAIL – synthetic session/evidence/transport only; B.3 requires user validation.")
    }
}
