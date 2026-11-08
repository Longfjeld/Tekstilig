// Test 242.3: caller-supplied evidence only. No decoding, IO or import decisions.
nonisolated enum BaselineEvidenceModel {
    enum Raw: Equatable {
        case missing, string(String), nonString(type: String, description: String)
        var text: String? { if case .string(let value) = self { value } else { nil } }
        var order: [String] {
            switch self {
            case .missing: return ["0"]
            case .string(let value): return ["1", value]
            case .nonString(let type, let description): return ["2", type, description]
            }
        }
    }
    struct Context: Equatable {
        let container, environment, account, database, zone, zoneOwner: Raw
        var fields: [Raw] { [container, environment, account, database, zone, zoneOwner] }
        var valid: Bool {
            fields.allSatisfy { token($0) } && ["Development", "Production"].contains(environment.text ?? "")
        }
    }
    // An explicit historical claim tied to this baseline, not a current observation.
    // The model checks structure/consistency; it cannot authenticate the source.
    struct HistoricalClaim: Equatable {
        let context: Context
        let evidenceSource: Raw
    }
    struct Record: Equatable {
        let recordType, recordName, changeTag: Raw
        var order: [String] { recordType.order + recordName.order + changeTag.order }
    }
    struct Baseline: Equatable {
        let journalID, zipSHA256: Raw
        let records: [Record]
        let historicalClaims: [HistoricalClaim]
    }
    struct Journal: Equatable {
        let journalID, zipSHA256: Raw
    }
    struct Input: Equatable {
        let selectedZipSHA256: Raw
        let journals: [Journal]
        let baselines: [Baseline]
        // Kept as raw input, never consulted as historical evidence.
        let currentContexts: [Context]
    }
    enum Status: String { case documented, unresolved, conflicting, ambiguous }
    enum Issue: String {
        case missingBaseline, multipleBaselines, missingJournal, multipleJournals
        case invalidZipHash, invalidJournalBinding, invalidBaselineBinding
        case journalIDMismatch, zipHashMismatch
        case missingRecords, invalidRecord, repeatedRecordAddress, conflictingRecordVersion
        case missingHistoricalContext, invalidHistoricalClaim, multipleHistoricalClaims, conflictingHistoricalContexts
    }
    struct Report: Equatable {
        let input: Input
        // Each baseline's full raw records, deterministically ordered; no deduplication.
        let recordGroups: [[Record]]
        let binding, observations, historicalContext: Status
        let issues: [Issue]
        var hasStop: Bool { !issues.isEmpty }
        var permitsImport: Bool { false }
        var permitsCloudKitWriting: Bool { false }
    }

    static func evaluate(_ input: Input) -> Report {
        var issues: [Issue] = []
        func add(_ issue: Issue) { issues.append(issue) }
        var binding = Status.documented
        var observations = Status.documented
        var history = Status.documented
        if !hash(input.selectedZipSHA256) { add(.invalidZipHash); binding = .unresolved }
        if input.journals.isEmpty { add(.missingJournal); binding = .unresolved }
        if input.journals.count > 1 { add(.multipleJournals); binding = .ambiguous }
        if input.baselines.isEmpty {
            add(.missingBaseline); binding = .unresolved; observations = .unresolved; history = .unresolved
        }
        if input.baselines.count > 1 {
            add(.multipleBaselines); binding = .ambiguous; observations = .ambiguous; history = .ambiguous
        }
        for journal in input.journals {
            if !uuid(journal.journalID) || !hash(journal.zipSHA256) {
                add(.invalidJournalBinding); if binding == .documented { binding = .unresolved }
            }
        }
        for baseline in input.baselines {
            if !uuid(baseline.journalID) || !hash(baseline.zipSHA256) {
                add(.invalidBaselineBinding); if binding == .documented { binding = .unresolved }
            }
            if baseline.records.isEmpty { add(.missingRecords); if observations == .documented { observations = .unresolved } }
            for record in baseline.records {
                if !["Textile", "Piece", "TextileMaterial", "TextileColor", "TextileImage"].contains(record.recordType.text ?? "") ||
                    !name(record.recordName) || !token(record.changeTag) {
                    add(.invalidRecord); if observations == .documented { observations = .unresolved }
                }
                let matches = baseline.records.filter { $0.recordType == record.recordType && $0.recordName == record.recordName }
                if matches.count > 1 {
                    add(.repeatedRecordAddress)
                    if observations != .conflicting { observations = .ambiguous }
                    if matches.contains(where: { $0.changeTag != record.changeTag }) {
                        add(.conflictingRecordVersion); observations = .conflicting
                    }
                }
            }
            if baseline.historicalClaims.isEmpty {
                add(.missingHistoricalContext); if history == .documented { history = .unresolved }
            }
            if baseline.historicalClaims.count > 1 {
                add(.multipleHistoricalClaims); if history != .conflicting { history = .ambiguous }
                if let first = baseline.historicalClaims.first,
                   baseline.historicalClaims.contains(where: { $0.context != first.context }) {
                    add(.conflictingHistoricalContexts); history = .conflicting
                }
            }
            for claim in baseline.historicalClaims where !claim.context.valid || !token(claim.evidenceSource) {
                add(.invalidHistoricalClaim); if history == .documented { history = .unresolved }
            }
        }
        // Only a unique pair can establish a binding. Never choose among candidates.
        if input.baselines.count == 1, input.journals.count == 1,
           let baseline = input.baselines.first, let journal = input.journals.first {
            if uuid(baseline.journalID), uuid(journal.journalID), baseline.journalID != journal.journalID {
                add(.journalIDMismatch); binding = .conflicting
            }
            if hash(input.selectedZipSHA256), hash(baseline.zipSHA256), hash(journal.zipSHA256),
               (baseline.zipSHA256 != journal.zipSHA256 || journal.zipSHA256 != input.selectedZipSHA256) {
                add(.zipHashMismatch); binding = .conflicting
            }
        }
        return Report(input: input, recordGroups: input.baselines.map { $0.records.sorted { $0.order.lexicographicallyPrecedes($1.order) } },
            binding: binding, observations: observations, historicalContext: history,
            issues: Array(Set(issues)).sorted { $0.rawValue < $1.rawValue })
    }

    private static func token(_ raw: Raw) -> Bool {
        guard let value = raw.text else { return false }
        return !value.isEmpty && value.utf8.allSatisfy { $0 >= 33 && $0 <= 126 }
    }
    private static func name(_ raw: Raw) -> Bool {
        guard let value = raw.text else { return false }
        return !value.isEmpty && value.utf8.count <= 255 && value.utf8.allSatisfy { $0 >= 32 && $0 <= 126 }
    }
    private static func hash(_ raw: Raw) -> Bool {
        guard let value = raw.text else { return false }
        return value.utf8.count == 64 && value.utf8.allSatisfy(hex)
    }
    private static func hex(_ byte: UInt8) -> Bool { (48...57).contains(byte) || (65...70).contains(byte) || (97...102).contains(byte) }
    private static func uuid(_ raw: Raw) -> Bool {
        guard let value = raw.text else { return false }
        let bytes = Array(value.utf8)
        return bytes.count == 36 && bytes.enumerated().allSatisfy {
            [8, 13, 18, 23].contains($0.offset) ? $0.element == 45 : hex($0.element)
        }
    }
}
