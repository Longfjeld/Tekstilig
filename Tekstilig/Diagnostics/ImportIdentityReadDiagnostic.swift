import Foundation

// Test 241 A. Transport is injected; this orchestrator never discovers files or accounts.
@MainActor
protocol ImportIdentityReadTransport {
    func context() async throws -> ImportIdentityReadDiagnostic.Context
    func page(type: ImportIdentityDecisionModel.RecordType, after cursor: String?) async throws -> ImportIdentityReadDiagnostic.Page
}

@MainActor
enum ImportIdentityReadDiagnostic {
    typealias M = ImportIdentityDecisionModel
    typealias A = ImportIdentityDiagnosticAdapter

    enum RawField: Equatable {
        case missing
        case string(String)
        case nonString(type: String, description: String)
        var string: String? { if case .string(let value) = self { return value }; return nil }
    }

    struct Observation: Equatable {
        let recordType: String
        let logicalID: RawField
        let owner: RawField
        let recordName: String
        let zone: String
        let zoneOwner: String
        let changeTag: String?
        var order: [String] {
            [recordType, recordName, zone, zoneOwner, String(reflecting: logicalID),
             String(reflecting: owner), String(reflecting: changeTag)]
        }
    }

    enum EnvironmentSource: Equatable { case signedApplicationEntitlement, unverified }
    struct Context: Equatable {
        let scope: M.Scope
        let environmentSource: EnvironmentSource
        let expectedEnvironment: CloudKitEnvironmentVerification.Environment?
    }
    struct Page {
        let observations: [Observation]
        let recordErrors: [String]
        let nextCursor: String?
    }
    struct ReadResult {
        let context: Context?
        let first: [Observation]
        let second: [Observation]
        let firstTypes: Set<M.RecordType>
        let secondTypes: Set<M.RecordType>
        let issues: [String]
        var hasStops: Bool { !issues.isEmpty }

        // Only current observations are scoped here. Never retrofit historical baseline scope.
        @MainActor
        func applying(to source: A.Snapshot) -> A.Snapshot {
            var target = source
            target.scope = context.flatMap { ImportIdentityReadDiagnostic.valid($0) ? $0.scope : nil }
            func scope(_ value: Observation) -> M.Scope? {
                context.map { c in M.Scope(container: c.scope.container, environment: c.scope.environment,
                    account: c.scope.account, database: c.scope.database, zone: value.zone, zoneOwner: value.zoneOwner) }
            }
            // Invalid/missing typed fields remain in first/second and issues. Empty placeholders
            // cannot authorize a decision: every extraction error reaches coverage.readErrors.
            target.observed = first.map { A.IdentityRecord(type: $0.recordType,
                logicalID: $0.logicalID.string ?? "", owner: $0.owner.string ?? "",
                recordName: $0.recordName, scope: scope($0)) }
            target.current = first.map { A.VersionRecord(type: $0.recordType,
                recordName: $0.recordName, changeTag: $0.changeTag ?? "", scope: scope($0)) }
            let complete = firstTypes == Set(M.RecordType.allCases) && secondTypes == firstTypes
            target.coverage = M.Coverage(verifiedIdentityTypes: firstTypes.intersection(secondTypes),
                completeNameInventory: complete && !hasStops, completeVersions: complete && !hasStops,
                readErrors: Array(Set(source.coverage.readErrors + issues)).sorted())
            target.rawIdentitiesVerified = complete
            return target
        }

        @MainActor
        func render(using source: A.Snapshot) -> String {
            let raw = [("Pass 1", first), ("Pass 2", second)].flatMap { label, values in
                ImportIdentityReadDiagnostic.ordered(values).map { "\(label) | \($0.recordType.debugDescription) | ID \(String(reflecting: $0.logicalID)) | eier \(String(reflecting: $0.owner)) | navn \($0.recordName.debugDescription) | zone \($0.zone.debugDescription) | zoneOwner \($0.zoneOwner.debugDescription) | tag \(String(reflecting: $0.changeTag))" }
            }
            return (["Test 241 A – \(hasStops ? "STOPP" : "to like, fullførte observasjonspasseringer"). Ingen atomisk snapshot eller skrivetillatelse.",
                "Kontekst/beviskilde: \(String(reflecting: context))"] +
                issues.map { "STOPP: " + $0 } + raw + [A.render(applying(to: source))]).joined(separator: "\n")
        }
    }

    static func idField(_ type: M.RecordType) -> String {
        switch type {
        case .textile: return "textileId"
        case .piece: return "pieceId"
        case .material: return "materialId"
        case .color: return "colorId"
        case .image: return "imageId"
        }
    }
    static func desiredKeys(_ type: M.RecordType) -> [String] {
        type == .textile ? [idField(type)] : [idField(type), "textileId"]
    }
    private static func token(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy { $0 >= 33 && $0 <= 126 }
    }
    static func valid(_ value: Context) -> Bool {
        let s = value.scope
        return value.environmentSource == .signedApplicationEntitlement &&
            value.expectedEnvironment?.rawValue == s.environment && s.database == "private" &&
            [s.container, s.account, s.zone, s.zoneOwner].allSatisfy(token)
    }
    private static func ordered(_ values: [Observation]) -> [Observation] {
        values.sorted { $0.order.lexicographicallyPrecedes($1.order) }
    }

    static func read(using transport: any ImportIdentityReadTransport) async -> ReadResult {
        var initial: Context?
        var passes = [[Observation](), [Observation]()]
        var completed = [Set<M.RecordType>(), Set<M.RecordType>()]
        var issues: [String] = []
        func result() -> ReadResult {
            ReadResult(context: initial, first: ordered(passes[0]), second: ordered(passes[1]),
                firstTypes: completed[0], secondTypes: completed[1], issues: Array(Set(issues)).sorted())
        }
        do {
            try Task.checkCancellation()
            let c = try await transport.context()
            initial = c
            guard valid(c) else { issues.append("Uverifisert/ugyldig CloudKit-kontekst"); return result() }
            for pass in 0..<2 {
                for type in M.RecordType.allCases {
                    var cursor: String?
                    var seenCursors = Set<String>()
                    repeat {
                        try Task.checkCancellation()
                        let page = try await transport.page(type: type, after: cursor)
                        // Retain successful records even if this page also has failures/cancellation.
                        passes[pass] += page.observations
                        issues += page.recordErrors.map { "\(type.rawValue) postfeil: " + $0 }
                        for item in page.observations {
                            let name = "\(item.recordType):\(item.recordName.debugDescription)"
                            if item.recordType != type.rawValue { issues.append("Feil posttype: " + name) }
                            if item.zone != c.scope.zone || item.zoneOwner != c.scope.zoneOwner { issues.append("Feil recordkontekst: " + name) }
                            if item.recordName.isEmpty || item.recordName.utf8.count > 255 ||
                                !item.recordName.utf8.allSatisfy({ $0 >= 32 && $0 <= 126 }) { issues.append("Ugyldig recordName: " + name) }
                            if item.logicalID.string.map(token) != true { issues.append("Ugyldig rå-ID: " + name) }
                            if item.owner.string.map(token) != true { issues.append("Ugyldig rå-eier: " + name) }
                            if item.changeTag.map(token) != true { issues.append("Manglende/ugyldig changeTag: " + name) }
                        }
                        try Task.checkCancellation()
                        if !issues.isEmpty { return result() }
                        cursor = page.nextCursor
                        if let cursor, cursor.isEmpty || !seenCursors.insert(cursor).inserted {
                            issues.append("Ugyldig/gjentatt cursor: \(type.rawValue)"); return result()
                        }
                    } while cursor != nil
                    completed[pass].insert(type)
                }
                // Physical addresses ignore recordType. Do not collapse duplicates into sets.
                let byAddress = Dictionary(grouping: passes[pass], by: { [$0.zone, $0.zoneOwner, $0.recordName] })
                for (_, values) in byAddress where values.count > 1 {
                    issues.append("Duplisert recordadresse: \(values[0].recordName.debugDescription)")
                }
                let byIdentity = Dictionary(grouping: passes[pass], by: { [$0.recordType, $0.logicalID.string ?? ""] })
                for (key, values) in byIdentity where values.count > 1 {
                    issues.append("Duplisert logisk identitet: \(key.map { $0.debugDescription }.joined(separator: ":"))")
                }
                let after = try await transport.context()
                try Task.checkCancellation()
                if after != c || !valid(after) { issues.append("CloudKit-kontekst/konto endret under lesing") }
                if !issues.isEmpty { return result() }
            }
            if ordered(passes[0]) != ordered(passes[1]) { issues.append("Observasjoner endret mellom passeringer") }
        } catch {
            issues.append(error is CancellationError ? "Lesing avbrutt" : "Lesefeil: \(String(describing: error))")
        }
        return result()
    }
}
