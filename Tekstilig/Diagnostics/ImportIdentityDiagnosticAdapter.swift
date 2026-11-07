// Test 240: value-only adapter and presentation. No IO or framework imports.
nonisolated enum ImportIdentityDiagnosticAdapter {
    typealias M = ImportIdentityDecisionModel

    struct IdentityRecord: Equatable {
        let type: String
        let logicalID: String
        let owner: String
        var recordName = ""
        var scope: M.Scope? = nil
    }

    struct VersionRecord: Equatable {
        let type: String
        let recordName: String
        let changeTag: String
        var scope: M.Scope? = nil
    }

    struct Journal: Equatable {
        let schemaVersion: Int
        let journalID: String
        let state: String
        let operationIDs: [String]
        let completedOperationCount: Int
        let zipSHA256: String
    }

    struct Baseline: Equatable {
        let schemaVersion: Int
        let journalID: String
        let zipSHA256: String
        let entries: [VersionRecord]
    }

    struct Snapshot: Equatable {
        var scope: M.Scope?
        var backup: [IdentityRecord]
        var observed: [IdentityRecord]
        var current: [VersionRecord]?
        var baseline: Baseline?
        var journal: Journal?
        var selectedZIPHash: String
        var coverage: M.Coverage
        var rawIdentitiesVerified: Bool
    }

    struct Adapted {
        let input: M.Input
        let issues: [String]
    }

    static func adapt(_ source: Snapshot) -> Adapted {
        var issues = source.coverage.readErrors
        // Empty fields explicitly fail model validation; never infer account/zone.
        let unresolved = M.Scope(container: "", environment: "", account: "", database: "", zone: "", zoneOwner: "")
        if source.scope == nil { issues.append("CloudKit-kontekst er ikke verifisert.") }
        if !source.rawIdentitiesVerified { issues.append("Råidentiteter/eierverdier er ikke verifisert; eksisterende bildeleser trimmer verdier.") }
        func type(_ value: String) -> M.RecordType? {
            guard let type = M.RecordType(rawValue: value) else {
                issues.append("Ukjent posttype: \(value.debugDescription)")
                return nil
            }
            return type
        }
        func identity(_ record: IdentityRecord) -> M.Identity? {
            type(record.type).map { M.Identity(key: M.Key(type: $0, logicalID: record.logicalID), owner: record.owner) }
        }
        func address(_ scope: M.Scope?, _ name: String) -> M.Address {
            if scope == nil { issues.append("Recordkontekst mangler: \(name.debugDescription)") }
            return M.Address(scope: scope ?? unresolved, recordName: name)
        }
        func versions(_ values: [VersionRecord]) -> [M.Version] {
            values.compactMap { value in
                guard let type = type(value.type) else { return nil }
                return M.Version(record: M.InventoryRecord(type: type,
                    address: address(value.scope, value.recordName)), changeTag: value.changeTag)
            }
        }
        let backup = source.backup.compactMap(identity)
        let observed = source.observed.compactMap { value -> M.Observed? in
            guard let identity = identity(value) else { return nil }
            return M.Observed(identity: identity, address: address(value.scope, value.recordName))
        }
        let current = source.current.map(versions)
        let baseline = source.baseline.map { versions($0.entries) }
        if let saved = source.baseline, saved.schemaVersion != 1 { issues.append("Ugyldig baselineformat.") }
        var binding: M.Binding?
        if let journal = source.journal, let saved = source.baseline {
            let operations = journal.operationIDs.compactMap { value -> M.Operation? in
                // This is the journal's documented type:ID encoding, never report text.
                guard let colon = value.firstIndex(of: ":"), let type = type(String(value[..<colon])) else {
                    issues.append("Ugyldig journaloperasjon: \(value.debugDescription)")
                    return nil
                }
                return M.Operation(key: M.Key(type: type, logicalID: String(value[value.index(after: colon)...])), state: .planned)
            }
            if journal.schemaVersion == 2 && journal.state == "planned-read-only" && journal.completedOperationCount == 0 {
                binding = M.Binding(selectedZIPHash: source.selectedZIPHash, journalZIPHash: journal.zipSHA256,
                    expectedJournalID: saved.journalID, journalID: journal.journalID,
                    baselineJournalID: saved.journalID, baselineZIPHash: saved.zipSHA256, operations: operations)
            } else {
                // A diagnostic count cannot be expanded into per-operation outcomes.
                issues.append("Journalen er ikke en uutført v2-diagnostikkplan; operasjonsutfall kan ikke avklares.")
            }
        }
        let orderedIssues = Array(Set(issues)).sorted()
        return Adapted(input: M.Input(scope: source.scope ?? unresolved, backup: backup, observed: observed,
            inventory: current?.map(\.record) ?? [], baseline: baseline, current: current, binding: binding,
            coverage: M.Coverage(verifiedIdentityTypes: source.coverage.verifiedIdentityTypes,
                completeNameInventory: source.coverage.completeNameInventory,
                completeVersions: source.coverage.completeVersions, readErrors: orderedIssues)), issues: orderedIssues)
    }

    static func render(_ source: Snapshot) -> String {
        let adapted = adapt(source)
        let report = M.evaluate(adapted.input)
        func key(_ value: M.Key) -> String { "\(value.type.rawValue):\(value.logicalID.debugDescription)" }
        func address(_ value: M.Address) -> String {
            let s = value.scope
            return [s.container, s.environment, s.account, s.database, s.zone, s.zoneOwner, value.recordName]
                .map { $0.debugDescription }.joined(separator: " / ")
        }
        func stop(_ value: M.Stop) -> String {
            value.code.rawValue + (value.key.map { " | " + key($0) } ?? "") +
                (value.address.map { " | " + address($0) } ?? "")
        }
        var lines = ["Test 240 – beslutningsrapport fra lagret minnegrunnlag (ingen nye lesinger).",
            "Status: \(report.hasStops ? "STOPP" : "Klassifisert – fortsatt ingen skrivetillatelse").",
            "CloudKit-skriving: \(report.permitsCloudKitWriting). Kandidater er ikke produksjonsgodkjent.",
            "Separate observasjoner er ikke atomiske; gjenbruk gir ingen tillatelse til innholdsoppdatering.",
            "Valgt ZIP SHA-256: \(source.selectedZIPHash)",
            "Journal-ID: \(source.journal?.journalID ?? "mangler"); journalhash: \(source.journal?.zipSHA256 ?? "mangler")",
            "Baseline-ID: \(source.baseline?.journalID ?? "mangler"); baselinehash: \(source.baseline?.zipSHA256 ?? "mangler")",
            "Operasjoner: \(source.journal?.operationIDs.count ?? 0); fullførte: \(source.journal.map { String($0.completedOperationCount) } ?? "ukjent")",
            "Lesedekning: \(source.coverage.verifiedIdentityTypes.map(\.rawValue).sorted().joined(separator: ", ")); inventar komplett: \(source.coverage.completeNameInventory); versjoner komplette: \(source.coverage.completeVersions); råverdier verifisert: \(source.rawIdentitiesVerified)."]
        lines += adapted.issues.map { "Uavklart grunnlag: " + $0 }
        // Preserve duplicates and original values in the audit presentation too.
        lines += source.backup.map {
            "Backup: \($0.type.debugDescription) | ID \($0.logicalID.debugDescription) | eier \($0.owner.debugDescription)"
        }.sorted()
        lines += source.observed.map {
            "Observasjon: \($0.type.debugDescription) | ID \($0.logicalID.debugDescription) | eier \($0.owner.debugDescription) | recordName \($0.recordName.debugDescription)"
        }.sorted()
        for (label, entries) in [("Baseline", source.baseline?.entries), ("Versjonsinventar", source.current)] {
            lines += (entries ?? []).map {
                "\(label): \($0.type.debugDescription) | recordName \($0.recordName.debugDescription) | tag \($0.changeTag.debugDescription)"
            }.sorted()
        }
        lines += (source.journal?.operationIDs ?? []).sorted().map { "Planlagt journaloperasjon: \($0.debugDescription)" }
        lines += report.globalStops.map { "Global stopp: " + stop($0) }
        for row in report.rows {
            let detail: String
            switch row.decision {
            case .reuseExisting(let actual): detail = "reuseExisting | eier \(actual.identity.owner.debugDescription) | " + address(actual.address)
            case .candidateForCreation(let candidate):
                detail = "candidateForCreation | eier \(candidate.identity.owner.debugDescription) | " + address(candidate.address) +
                    " | \(candidate.strategyVersion) | forelder \(candidate.parent.map(key) ?? "ingen") | approvedForProduction: false"
            case .stopConflict(let stops): detail = "stopConflict | " + stops.map(stop).joined(separator: "; ")
            case .stopInvalidBasis(let stops): detail = "stopInvalidBasis | " + stops.map(stop).joined(separator: "; ")
            }
            lines.append(key(row.key) + " | " + detail)
        }
        return lines.joined(separator: "\n")
    }
}
