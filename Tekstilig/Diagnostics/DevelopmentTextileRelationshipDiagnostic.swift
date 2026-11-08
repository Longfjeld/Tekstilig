#if os(macOS) && DEBUG
// Presentation only. All data comes from the existing explicit B.3 session.
@MainActor
enum DevelopmentTextileRelationshipDiagnostic {
    typealias D = ImportIdentityReadDiagnostic
    typealias E = CloudKitEnvironmentVerification
    typealias A = TextileRelationshipReadAdapter
    struct Presentation {
        let source: D.ReadResult?
        let adapted: A.Result?
        let readComplete: Bool
        let text: String
        var hasStop: Bool { !readComplete || adapted?.hasStop != false }
        var permitsCloudKitWriting: Bool { false }
    }

    static func make(result: D.ReadResult?, environment: E.Outcome?, issues: [String],
                     isRunning: Bool, cancellationRequested: Bool) -> Presentation {
        var sessionIssues = issues
        if environment != .verified(.development) { sessionIssues.append("Lokal Development-kontroll ikke godkjent") }
        if isRunning { sessionIssues.append("Lesing pågår – grunnlaget er ikke avsluttet") }
        if cancellationRequested { sessionIssues.append("Avbrudd er bedt om – grunnlaget godkjennes ikke som komplett") }
        var lines = ["Test 242.5 – isolert relasjonsdiagnostikk. Forventet miljø: Development.",
            "CloudKit-skrivetillatelse: false. Ingen importbeslutning, reparasjon eller lagring.",
            "Like passeringer er ikke et atomisk snapshot. Ingen historisk baseline- eller slettingskonklusjon.",
            "Lokal miljøkontroll: \(String(reflecting: environment))"]
        guard let result else {
            lines += sessionIssues.sorted().map { "STOPP: " + $0 }
            lines.append("Lesing: IKKE KOMPLETT / ingen leseresultat. Ingen relasjoner vurdert.")
            return Presentation(source: nil, adapted: nil, readComplete: false, text: lines.joined(separator: "\n"))
        }
        // Preserve original source separately; session-level failures also constrain the adapter.
        if result.context?.scope.environment != "Development" || result.context?.expectedEnvironment != .development {
            sessionIssues.append("Leseresultatets miljø/forventning er ikke bekreftet Development")
        }
        let constrained = D.ReadResult(context: result.context, first: result.first, second: result.second,
            firstTypes: result.firstTypes, secondTypes: result.secondTypes, issues: result.issues + sessionIssues)
        let adapted = A.adapt(constrained)
        let complete = adapted.issues.isEmpty && adapted.firstInput.coverage.count == 1 &&
            adapted.secondInput.coverage.count == 1 && adapted.firstInput.coverage[0].textileReadComplete &&
            adapted.secondInput.coverage[0].textileReadComplete
        lines.append("Lesing: \(complete ? "KOMPLETT i oppgitt leseområde" : "IKKE KOMPLETT / STOPP").")
        lines.append("Relasjonsvurdering: \(adapted.hasStop ? "STOPP" : "OBSERVERT"). Et relasjonsavvik kan forekomme ved komplett lesing.")
        lines.append("Innsendt kontekst/beviskilde: \(String(reflecting: result.context))")
        lines += adapted.issues.map { "STOPP: " + $0 }
        for (label, values, types, report) in [
            ("Pass 1", result.first, result.firstTypes, adapted.first),
            ("Pass 2", result.second, result.secondTypes, adapted.second)
        ] {
            lines.append("\(label): \(values.count) råobservasjoner; \(report.rows.count) underpostrader; fullførte typer: \(types.map(\.rawValue).sorted().joined(separator: ", "))")
            // Unknown types and all raw fields remain visible, beyond the four known child types.
            for row in values.sorted(by: { $0.order.lexicographicallyPrecedes($1.order) }) {
                lines.append("\(label) RÅ | \(row.recordType.debugDescription) | ID \(String(reflecting: row.logicalID)) | eier \(String(reflecting: row.owner)) | recordName \(row.recordName.debugDescription) | zone \(row.zone.debugDescription) | zoneOwner \(row.zoneOwner.debugDescription) | changeTag \(String(reflecting: row.changeTag))")
            }
            lines += ["\(label) RELASJONER:", report.text]
        }
        return Presentation(source: result, adapted: adapted, readComplete: complete, text: lines.joined(separator: "\n"))
    }
}
#endif
