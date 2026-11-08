#if os(macOS) && DEBUG
import Combine
import Foundation

// Factories are inert until an explicit start. No filesystem or default live transport.
@MainActor
final class DevelopmentIdentityReadSession: ObservableObject {
    typealias D = ImportIdentityReadDiagnostic
    typealias E = CloudKitEnvironmentVerification
    @Published private(set) var isRunning = false
    @Published private(set) var cancellationRequested = false
    @Published private(set) var environment: E.Outcome?
    @Published private(set) var result: D.ReadResult?
    @Published private(set) var issues: [String] = []
    private let makeSource: () -> any CloudKitEnvironmentEvidenceSource
    private let makeTransport: (E.Environment) -> any ImportIdentityReadTransport
    private var task: Task<Void, Never>?

    init(makeSource: @escaping () -> any CloudKitEnvironmentEvidenceSource,
         makeTransport: @escaping (E.Environment) -> any ImportIdentityReadTransport) {
        self.makeSource = makeSource
        self.makeTransport = makeTransport
    }

    @discardableResult
    func start() -> Task<Void, Never>? {
        guard !isRunning else { return nil }
        isRunning = true
        cancellationRequested = false
        environment = nil
        result = nil
        issues = []
        let work = Task { @MainActor [self] in
            defer { isRunning = false; task = nil }
            guard !Task.isCancelled else { issues = ["Lesing avbrutt før miljøkontroll"]; return }
            let proof = E.evaluate(source: makeSource(), expected: .development)
            environment = proof
            guard proof == .verified(.development) else { issues = ["Miljøkontroll avvist: \(String(reflecting: proof))"]; return }
            guard !Task.isCancelled else { issues = ["Lesing avbrutt før transportopprettelse"]; return }
            let transport = makeTransport(.development)
            result = await D.read(using: transport)
            if Task.isCancelled { issues = ["Lesing avbrutt"] }
        }
        task = work
        return work
    }

    func cancel() {
        guard isRunning else { return }
        cancellationRequested = true
        task?.cancel()
    }

    var report: String {
        Self.render(result: result, environment: environment, issues: issues)
    }

    // Observation-only report. No Snapshot, backup/journal/baseline or import decisions.
    static func render(result: D.ReadResult?, environment: E.Outcome?, issues: [String]) -> String {
        var lines = ["Test 241 B.3 – kun identiteter/metadata. Forventet miljø: Development.",
            "Ingen atomisk snapshot, importbeslutning eller skrivetillatelse.",
            "Foreldre-/eierrelasjoner og historisk baselinebinding er ikke fullstendig verifisert."]
        if let environment {
            lines.append("Lokal miljøkontroll: \(String(reflecting: environment))")
            lines.append(environment == .verified(.development)
                ? "Lokalt bevis: validert prosessignatur og eksakt CloudKit-miljøentitlement. Transporten kontrollerer dette på nytt."
                : "Lokalt bevis: ikke godkjent for Development; transport skal ikke opprettes.")
        } else { lines.append("Miljøkontroll ikke utført.") }
        lines += issues.map { "STOPP: " + $0 }
        guard let result else {
            lines.append(issues.isEmpty ? "Lesing ikke startet/fullført. Ingen observerte poster." : "Ingen CloudKit-leseresultat.")
            return lines.joined(separator: "\n")
        }
        lines.append(result.hasStops || !issues.isEmpty ? "STOPP – ufullstendig/avvist leseresultat." : "To like, fullførte observasjonspasseringer i valgt leseområde.")
        if let context = result.context {
            let s = context.scope
            lines += ["Container: \(s.container.debugDescription)", "Miljø: \(s.environment.debugDescription); forventet: \(String(reflecting: context.expectedEnvironment))",
                "Konto (CloudKit-recordName): \(s.account.debugDescription)", "Database: \(s.database.debugDescription)",
                "Konfigurert zone: \(s.zone.debugDescription); zoneOwner: \(s.zoneOwner.debugDescription)",
                "Kontekstens beviskilde: \(String(reflecting: context.environmentSource))"]
        } else { lines.append("Kontekst ikke etablert.") }
        lines += result.issues.map { "STOPP: " + $0 }
        for (label, rows, types) in [("Pass 1", result.first, result.firstTypes), ("Pass 2", result.second, result.secondTypes)] {
            lines.append("\(label): \(rows.count) observerte poster; fullførte typer: \(types.map(\.rawValue).sorted().joined(separator: ", "))")
            for type in ImportIdentityDecisionModel.RecordType.allCases {
                lines.append("\(label) antall \(type.rawValue): \(rows.filter { $0.recordType == type.rawValue }.count); fullført: \(types.contains(type))")
            }
            for row in rows.sorted(by: { $0.order.lexicographicallyPrecedes($1.order) }) {
                lines.append("\(label) | \(row.recordType.debugDescription) | rå-ID \(String(reflecting: row.logicalID)) | rå-eier \(String(reflecting: row.owner)) | recordName \(row.recordName.debugDescription) | observert zone \(row.zone.debugDescription) | zoneOwner \(row.zoneOwner.debugDescription) | changeTag \(String(reflecting: row.changeTag))")
            }
        }
        return lines.joined(separator: "\n")
    }
}
#endif
