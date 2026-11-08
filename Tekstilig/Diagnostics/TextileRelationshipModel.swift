// Test 242.1: value-only relationship observations. No IO or import decisions.
nonisolated enum TextileRelationshipModel {
    enum ChildType: String, CaseIterable {
        case piece = "Piece", material = "TextileMaterial", color = "TextileColor", image = "TextileImage"
    }
    enum RawField: Equatable {
        case missing, string(String), nonString(type: String, description: String)
        var order: [String] {
            switch self {
            case .missing: return ["0"]
            case .string(let value): return ["1", value]
            case .nonString(let type, let description): return ["2", type, description]
            }
        }
        var token: String? {
            if case .string(let value) = self, TextileRelationshipModel.validToken(value) { return value }
            return nil
        }
    }
    struct Scope: Equatable {
        let container: String
        let environment: String
        let account: String
        let database: String
        let zone: String
        let zoneOwner: String
        var fields: [String] { [container, environment, account, database, zone, zoneOwner] }
        var valid: Bool { fields.allSatisfy(TextileRelationshipModel.validToken) }
    }
    struct Parent: Equatable {
        let logicalID: RawField
        let recordName: String
        let scope: Scope?
        let changeTag: String?
        var order: [String] { logicalID.order + [recordName] + scopeOrder(scope) + optionalOrder(changeTag) }
    }
    struct Child: Equatable {
        let type: ChildType
        let logicalID: RawField
        let owner: RawField
        let recordName: String
        let scope: Scope?
        let changeTag: String?
        var order: [String] { [type.rawValue] + logicalID.order + owner.order + [recordName] + scopeOrder(scope) + optionalOrder(changeTag) }
    }
    // Caller-supplied evidence for Textile coverage in exactly one scope, never inferred.
    struct Coverage: Equatable {
        let scope: Scope
        let contextVerified: Bool
        let textileReadComplete: Bool
        let readIssues: [String]
        var order: [String] { scope.fields + [String(contextVerified), String(textileReadComplete)] + readIssues }
    }
    struct Input: Equatable {
        let parents: [Parent]
        let children: [Child]
        let coverage: [Coverage]
    }
    enum Outcome: String {
        case uniqueObservedParent, parentNotObservedWithCompleteCoverage
        case incompleteCoverage, ambiguousParent, invalidOwner
    }
    enum Reason: String {
        case invalidOwner, missingOrInvalidChildScope, missingCoverage, ambiguousCoverage
        case unverifiedContext, incompleteTextileRead, readIssues
        case unscopedParentObservation, invalidParentObservation
    }
    struct Row: Equatable {
        let child: Child
        let matchingParents: [Parent]
        let outcome: Outcome
        let reasons: [Reason]
    }
    struct Report: Equatable {
        let parents: [Parent]
        let coverage: [Coverage]
        let rows: [Row]
        var permitsCloudKitWriting: Bool { false }
    }

    static func evaluate(_ input: Input) -> Report {
        let parents = input.parents.sorted { $0.order.lexicographicallyPrecedes($1.order) }
        let coverage = input.coverage.map {
            Coverage(scope: $0.scope, contextVerified: $0.contextVerified,
                textileReadComplete: $0.textileReadComplete, readIssues: $0.readIssues.sorted())
        }.sorted { $0.order.lexicographicallyPrecedes($1.order) }
        let rows = input.children.sorted { $0.order.lexicographicallyPrecedes($1.order) }.map { child -> Row in
            let matches = parents.filter {
                child.scope != nil && $0.scope == child.scope && $0.logicalID.token != nil && $0.logicalID.token == child.owner.token
            }
            func row(_ outcome: Outcome, _ reasons: [Reason] = []) -> Row {
                Row(child: child, matchingParents: matches, outcome: outcome, reasons: reasons.sorted { $0.rawValue < $1.rawValue })
            }
            // Invalid raw owner is diagnosed even if coverage/context is also missing.
            guard child.owner.token != nil else { return row(.invalidOwner, [.invalidOwner]) }
            guard let scope = child.scope, scope.valid else {
                return row(.incompleteCoverage, [.missingOrInvalidChildScope])
            }
            let evidence = coverage.filter { $0.scope == scope }
            var reasons: [Reason] = []
            if evidence.isEmpty { reasons.append(.missingCoverage) }
            if evidence.count > 1 { reasons.append(.ambiguousCoverage) }
            for value in evidence {
                if !value.contextVerified { reasons.append(.unverifiedContext) }
                if !value.textileReadComplete { reasons.append(.incompleteTextileRead) }
                if !value.readIssues.isEmpty { reasons.append(.readIssues) }
            }
            // Unknown parent context cannot safely be excluded from this scope.
            if parents.contains(where: { $0.scope?.valid != true }) { reasons.append(.unscopedParentObservation) }
            if parents.contains(where: { $0.scope == scope && ($0.logicalID.token == nil || !validRecordName($0.recordName)) }) {
                reasons.append(.invalidParentObservation)
            }
            guard reasons.isEmpty else { return row(.incompleteCoverage, Array(Set(reasons))) }
            if matches.count > 1 { return row(.ambiguousParent) }
            return row(matches.isEmpty ? .parentNotObservedWithCompleteCoverage : .uniqueObservedParent)
        }
        return Report(parents: parents, coverage: coverage, rows: rows)
    }

    private static func validToken(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy { $0 >= 33 && $0 <= 126 }
    }
    private static func validRecordName(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.count <= 255 && value.utf8.allSatisfy { $0 >= 32 && $0 <= 126 }
    }
    private static func scopeOrder(_ scope: Scope?) -> [String] { scope.map { ["1"] + $0.fields } ?? ["0"] }
    private static func optionalOrder(_ value: String?) -> [String] { value.map { ["1", $0] } ?? ["0"] }
}
