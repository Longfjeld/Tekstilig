// Test 242.4: adapts an already available result; never starts transport or parses text.
@MainActor
enum TextileRelationshipReadAdapter {
    typealias D = ImportIdentityReadDiagnostic
    typealias M = TextileRelationshipModel
    struct Result {
        let source: D.ReadResult
        let issues: [String]
        let firstInput: M.Input
        let secondInput: M.Input
        let first: TextileRelationshipReport.Report
        let second: TextileRelationshipReport.Report
        var hasStop: Bool { !issues.isEmpty || first.hasStops || second.hasStops }
        var permitsCloudKitWriting: Bool { false }
    }

    static func adapt(_ source: D.ReadResult) -> Result {
        var issues = source.issues // Keep duplicate error messages, including cancellation.
        let allTypes = Set(ImportIdentityDecisionModel.RecordType.allCases)
        let contextVerified = source.context.map(D.valid) == true
        if !contextVerified { issues.append("Uverifisert/manglende lesekontekst") }
        if source.firstTypes != allTypes { issues.append("Pass 1: ufullstendig typedekning") }
        if source.secondTypes != allTypes { issues.append("Pass 2: ufullstendig typedekning") }
        let firstOrdered = source.first.sorted { $0.order.lexicographicallyPrecedes($1.order) }
        let secondOrdered = source.second.sorted { $0.order.lexicographicallyPrecedes($1.order) }
        if firstOrdered != secondOrdered { issues.append("Observasjoner avviker mellom passeringene") }

        // ReadResult can also be constructed synthetically. Do not trust an empty issues list
        // to prove raw-field validity or consistency of the caller-supplied completion flags.
        for (index, values) in [source.first, source.second].enumerated() {
            let label = "Pass \(index + 1)"
            for value in values {
                let address = value.recordName.debugDescription
                if !allTypes.contains(where: { $0.rawValue == value.recordType }) {
                    issues.append("\(label): ukjent posttype \(value.recordType.debugDescription)")
                }
                if !token(value.logicalID.string) || !token(value.owner.string) || !token(value.changeTag) ||
                    value.recordName.isEmpty || value.recordName.utf8.count > 255 ||
                    !value.recordName.utf8.allSatisfy({ $0 >= 32 && $0 <= 126 }) {
                    issues.append("\(label): ugyldig råidentitet/metadata \(address)")
                }
                if value.recordType == "Textile", value.logicalID != value.owner {
                    issues.append("\(label): motstridende Textile-ID/eier \(address)")
                }
                if let context = source.context,
                   value.zone != context.scope.zone || value.zoneOwner != context.scope.zoneOwner {
                    issues.append("\(label): recordkontekst utenfor leseområdet \(address)")
                }
            }
            let addresses = Dictionary(grouping: values, by: { [$0.zone, $0.zoneOwner, $0.recordName] })
            for (key, matches) in addresses where matches.count > 1 {
                issues.append("\(label): duplisert recordadresse \(key.map { $0.debugDescription }.joined(separator: ":"))")
            }
            // Preserve malformed IDs in source/mapped input; only valid strings participate
            // in logical duplicate detection, with exact type and value, never normalization.
            let identities = Dictionary(grouping: values.filter { token($0.logicalID.string) },
                by: { [$0.recordType, $0.logicalID.string ?? ""] })
            for (key, matches) in identities where matches.count > 1 {
                issues.append("\(label): duplisert logisk identitet \(key.map { $0.debugDescription }.joined(separator: ":"))")
            }
        }
        issues.sort()
        let complete = contextVerified && source.firstTypes == allTypes && source.secondTypes == allTypes && issues.isEmpty
        func scope(_ zone: String, _ owner: String) -> M.Scope? {
            source.context.map { c in
                M.Scope(container: c.scope.container, environment: c.scope.environment, account: c.scope.account,
                    database: c.scope.database, zone: zone, zoneOwner: owner)
            }
        }
        func input(_ values: [D.Observation]) -> M.Input {
            let parents = values.filter { $0.recordType == "Textile" }.map {
                M.Parent(logicalID: raw($0.logicalID), recordName: $0.recordName,
                    scope: scope($0.zone, $0.zoneOwner), changeTag: $0.changeTag)
            }
            let children = values.compactMap { value -> M.Child? in
                guard let type = M.ChildType(rawValue: value.recordType) else { return nil }
                return M.Child(type: type, logicalID: raw(value.logicalID), owner: raw(value.owner),
                    recordName: value.recordName, scope: scope(value.zone, value.zoneOwner), changeTag: value.changeTag)
            }
            // Coverage is only for the explicitly requested scope, never another observed zone.
            let coverage = source.context.map { c in
                [M.Coverage(scope: M.Scope(container: c.scope.container, environment: c.scope.environment,
                    account: c.scope.account, database: c.scope.database, zone: c.scope.zone, zoneOwner: c.scope.zoneOwner),
                    contextVerified: contextVerified, textileReadComplete: complete, readIssues: issues)]
            } ?? []
            return M.Input(parents: parents, children: children, coverage: coverage)
        }
        let first = input(source.first), second = input(source.second)
        return Result(source: source, issues: issues, firstInput: first, secondInput: second,
            first: TextileRelationshipReport.make(first), second: TextileRelationshipReport.make(second))
    }

    private static func raw(_ value: D.RawField) -> M.RawField {
        switch value {
        case .missing: return .missing
        case .string(let string): return .string(string)
        case .nonString(let type, let description): return .nonString(type: type, description: description)
        }
    }
    private static func token(_ value: String?) -> Bool {
        value.map { !$0.isEmpty && $0.utf8.allSatisfy { $0 >= 33 && $0 <= 126 } } == true
    }
}
