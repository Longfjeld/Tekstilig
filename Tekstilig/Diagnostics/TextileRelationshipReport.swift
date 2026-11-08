// Test 242.2: in-memory presentation of the unchanged 242.1 model. No IO.
nonisolated enum TextileRelationshipReport {
    typealias M = TextileRelationshipModel
    struct Row: Equatable {
        let observation: M.Row
        let explanation: String
        var hasStop: Bool { observation.outcome != .uniqueObservedParent }
        var text: String {
            let child = observation.child
            return [child.type.rawValue, "rå-ID: \(raw(child.logicalID))", "rå-eier: \(raw(child.owner))",
                "recordName: \(child.recordName.debugDescription)", context(child.scope), "changeTag: \(optional(child.changeTag))",
                "foreldretreff: \(observation.matchingParents.count) [\(observation.matchingParents.map(parent).joined(separator: "; "))]",
                "utfall: \(observation.outcome.rawValue)", "årsaker: [\(observation.reasons.map(\.rawValue).joined(separator: ", "))]",
                "begrunnelse: \(explanation)", hasStop ? "STOPP" : "OBSERVERT"].joined(separator: " | ")
        }
    }
    struct Report: Equatable {
        let basis: M.Report
        let rows: [Row]
        var hasStops: Bool { rows.isEmpty || rows.contains { $0.hasStop } }
        var permitsCloudKitWriting: Bool { false }
        var text: String {
            var lines = ["Test 242.2 – isolert relasjonsrapport: \(hasStops ? "STOPP" : "OBSERVASJONER").",
                "CloudKit-skrivetillatelse: false. Ingen importbeslutning, reparasjon eller historisk slettingskonklusjon.",
                "Kalleren leverer kontekst/dekning. Ingen atomisitetsgaranti eller verifikasjon av historisk baseline, underpost-ID eller versjoner.",
                "Underpostrader: \(rows.count); foreldreobservasjoner: \(basis.parents.count); dekningsoppføringer: \(basis.coverage.count)."]
            if rows.isEmpty { lines.append("STOPP: Ingen underpostobservasjoner – ingen relasjoner vurdert.") }
            for type in M.ChildType.allCases {
                lines.append("Antall \(type.rawValue): \(rows.filter { $0.observation.child.type == type }.count)")
            }
            lines.append("DEKNINGSGRUNNLAG (alle oppføringer, også ufullstendige/dupliserte):")
            for coverage in basis.coverage {
                lines.append([context(coverage.scope), "kontekstverifisert: \(coverage.contextVerified)",
                    "Textile-lesing komplett: \(coverage.textileReadComplete)",
                    "lesefeil: [\(coverage.readIssues.map { $0.debugDescription }.joined(separator: ", "))]"].joined(separator: " | "))
            }
            lines.append("FORELDREGRUNNLAG (alle observasjoner, også ugyldige/dupliserte):")
            lines += basis.parents.map(parent)
            lines.append("UNDERPOSTRADER (én per innsendt observasjon):")
            lines += rows.map(\.text)
            return lines.joined(separator: "\n")
        }
    }

    static func make(_ input: M.Input) -> Report {
        let basis = M.evaluate(input)
        return Report(basis: basis, rows: basis.rows.map { row in
            Row(observation: row, explanation: explanation(row))
        })
    }

    private static func explanation(_ row: M.Row) -> String {
        switch row.outcome {
        case .uniqueObservedParent:
            return "Nøyaktig én gyldig forelder observert i samme kontekst ved komplett dekningsgrunnlag."
        case .parentNotObservedWithCompleteCoverage:
            return "Forelder ikke observert i det oppgitte komplette leseområdet; dette beviser ikke historisk sletting eller datakorrupsjon."
        case .ambiguousParent:
            return "\(row.matchingParents.count) matchende foreldreobservasjoner i samme kontekst; ingen forelder er valgt."
        case .incompleteCoverage, .invalidOwner:
            return row.reasons.map { reason -> String in
                switch reason {
                case .invalidOwner:
                    switch row.child.owner {
                    case .missing: return "Eierfelt mangler."
                    case .nonString: return "Eierfelt har feil datatype; råverdi/type er bevart."
                    case .string: return "Eierstrengen er tom eller utenfor diagnostikkens tokenregel; ingen normalisering utført."
                    }
                case .missingOrInvalidChildScope: return "Underpostens fullstendige CloudKit-kontekst mangler eller er ugyldig."
                case .missingCoverage: return "Ingen dekningsoppføring for underpostens eksakte CloudKit-kontekst."
                case .ambiguousCoverage: return "Flere dekningsoppføringer for samme kontekst; ingen er valgt."
                case .unverifiedContext: return "Dekningsgrunnlaget bekrefter ikke CloudKit-konteksten."
                case .incompleteTextileRead: return "Textile-lesingen er ikke komplett; fravær eller entydighet kan ikke fastslås."
                case .readIssues: return "Dekningsgrunnlaget inneholder lesefeil; feiltekst og duplikater er bevart i dekningsoversikten."
                case .unscopedParentObservation: return "En foreldreobservasjon har ukjent/ugyldig kontekst og kan ikke utelukkes fra leseområdet."
                case .invalidParentObservation: return "En foreldre-ID eller et foreldre-recordnavn i samme kontekst er ugyldig."
                }
            }.joined(separator: " ")
        }
    }
    private static func raw(_ field: M.RawField) -> String {
        switch field {
        case .missing: return "mangler"
        case .string(let value): return "streng(\(value.debugDescription))"
        case .nonString(let type, let description): return "feiltype(type: \(type.debugDescription), verdi: \(description.debugDescription))"
        }
    }
    private static func optional(_ value: String?) -> String { value.map { $0.debugDescription } ?? "mangler" }
    private static func context(_ scope: M.Scope?) -> String {
        guard let scope else { return "kontekst: mangler" }
        return "kontekst: {container: \(scope.container.debugDescription), miljø: \(scope.environment.debugDescription), konto: \(scope.account.debugDescription), database: \(scope.database.debugDescription), zone: \(scope.zone.debugDescription), zoneOwner: \(scope.zoneOwner.debugDescription)}"
    }
    private static func parent(_ value: M.Parent) -> String {
        "{rå-ID: \(raw(value.logicalID)), recordName: \(value.recordName.debugDescription), \(context(value.scope)), changeTag: \(optional(value.changeTag))}"
    }
}
