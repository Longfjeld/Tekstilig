import Foundation

/// Test 238: comparison and formatting only; no filesystem or CloudKit access.
enum ImportIdentityReport {
    struct Entry {
        let type: String
        let logicalID: String
        let owner: String
        var recordName: String = ""
        var key: String { "\(type):\(logicalID)" }
    }

    static let types = ["Textile", "Piece", "TextileMaterial", "TextileColor", "TextileImage"]

    static func backupEntries(_ backup: TekstiligBackupDocument) -> [Entry] {
        backup.textiles.flatMap { textile -> [Entry] in
            [Entry(type: "Textile", logicalID: textile.textileID, owner: textile.textileID)] +
            textile.pieces.map { Entry(type: "Piece", logicalID: $0.pieceID, owner: textile.textileID) } +
            textile.materials.map { Entry(type: "TextileMaterial", logicalID: $0.materialID, owner: textile.textileID) } +
            textile.colors.map { Entry(type: "TextileColor", logicalID: $0.colorID, owner: textile.textileID) } +
            textile.images.map { Entry(type: "TextileImage", logicalID: $0.imageID, owner: textile.textileID) }
        }
    }

    static func candidateName(for key: String) -> String {
        "tekstilig-import-v1-" + key.utf8.map { String(format: "%02x", $0) }.joined()
    }

    static func render(backup: [Entry], live: [Entry], journalOperations: Set<String>?,
                       baselineTags: [String: String]?, currentTags: [String: String]?) -> String {
        let expected = Dictionary(grouping: backup, by: \.key)
        let observed = Dictionary(grouping: live, by: \.key)
        let names = Dictionary(grouping: live, by: \.recordName)
        let parentIDs = Set(live.filter { $0.type == "Textile" }.map(\.logicalID))
        let keys = Set(expected.keys).union(observed.keys).sorted()
        var lines = types.map { type in
            "\(type): backup \(backup.filter { $0.type == type }.count), CloudKit \(live.filter { $0.type == type }.count)"
        }
        for key in keys {
            let wanted = expected[key] ?? []
            let actual = (observed[key] ?? []).sorted {
                ($0.recordName, $0.owner) < ($1.recordName, $1.owner)
            }
            guard let sample = wanted.first ?? actual.first else { continue }
            let owners = Set(wanted.map(\.owner))
            let candidate = candidateName(for: key)
            let collisions = (names[candidate] ?? []).sorted { ($0.key, $0.owner) < ($1.key, $1.owner) }
            var issues: [String] = []
            if wanted.count > 1 { issues.append("Duplisert logisk ID i backup (\(wanted.count)); tvetydig identitet") }
            if actual.count > 1 { issues.append("Duplisert logisk ID i CloudKit (\(actual.count)); tvetydig identitet") }
            if owners.count > 1 { issues.append("Tvetydig forventet tekstileier") }
            if sample.logicalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("Tom logisk ID")
            }
            if wanted.contains(where: { $0.owner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ||
                actual.contains(where: { $0.owner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $0.recordName.isEmpty }) {
                issues.append("Tom eier eller faktisk recordnavn")
            }
            if !wanted.isEmpty && actual.contains(where: { !owners.contains($0.owner) }) {
                issues.append("Feil tekstileier relativt til backup")
            }
            if sample.type != "Textile" && actual.contains(where: { !parentIDs.contains($0.owner) }) {
                issues.append("CloudKit-underpost uten observert tekstilforelder")
            }
            if !wanted.isEmpty && actual.isEmpty {
                issues.append(sample.type == "Textile" ? "Tekstil ikke observert i CloudKit" :
                    "Manglende underpost i CloudKit" +
                    (owners.contains(where: { parentIDs.contains($0) }) ? " under eksisterende tekstil" : " (tekstilforelder heller ikke observert)"))
            }
            if wanted.isEmpty { issues.append("CloudKit-post uten tilsvarende post i valgt backup") }
            if candidate.utf8.count > 255 { issues.append("Beregnet kandidatnavn over 255 byte") }
            if !collisions.isEmpty {
                issues.append("Kandidatnavn er allerede i bruk: " + collisions.map { "\($0.key), eier \($0.owner)" }.joined(separator: "; "))
            }
            if actual.contains(where: { (names[$0.recordName] ?? []).count > 1 }) {
                issues.append("Faktisk recordnavn forekommer flere ganger i innleste identiteter")
            }
            lines.append("\nPosttype: \(sample.type) | Logisk ID: \(sample.logicalID.debugDescription)")
            lines.append("Forventet eier fra backup: " + (wanted.isEmpty ? "ikke i backup" : wanted.map(\.owner).sorted().map { $0.debugDescription }.joined(separator: ", ")))
            lines.append("Observerte CloudKit-poster (\(actual.count)):")
            for entry in actual {
                let versionKey = "\(entry.type):\(entry.recordName)"
                lines.append("  Faktisk eier: \(entry.owner.debugDescription) | recordName: \(entry.recordName.debugDescription)")
                lines.append("  Baseline-tag: \(baselineTags?[versionKey] ?? "ikke verifisert/ikke i baseline") | ny versjonslesing: \(currentTags?[versionKey] ?? "ikke tilgjengelig")")
            }
            lines.append("Beregnet kandidatnavn (kun hypotese): \(candidate)")
            lines.append("I v2-journal: " + (journalOperations.map { $0.contains(key) ? "ja" : "nei" } ?? "ikke verifisert"))
            lines.append("Observasjoner/avvik: " + (issues.isEmpty ? "Ingen påvist i innleste data" : issues.joined(separator: "; ")))
        }
        return lines.joined(separator: "\n")
    }
}
