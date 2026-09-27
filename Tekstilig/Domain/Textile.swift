import Foundation

struct Textile: Identifiable, Hashable {
    var textileID: String
    var cloudRecordName: String?
    var name: String
    var category: String
    var createdAt: Date
    var updatedAt: Date
    var schemaVersion: Int

    var id: String {
        textileID
    }

    static let categoryOptions = [
        "Vevd",
        "Strikket",
        "Filt/non-woven",
        "Kunstskinn/skinn",
        "Annet",
        "Ukjent"
    ]

    static func newDraft() -> Textile {
        let now = Date()

        return Textile(
            textileID: "T-\(UUID().uuidString.uppercased())",
            cloudRecordName: nil,
            name: "",
            category: "",
            createdAt: now,
            updatedAt: now,
            schemaVersion: 1
        )
    }
}
