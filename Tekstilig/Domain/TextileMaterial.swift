import Foundation

struct TextileMaterial: Identifiable, Hashable {
    var materialID: String
    var cloudRecordName: String?
    var textileID: String
    var material: String
    var percent: Int64?

    var id: String {
        cloudRecordName ?? materialID
    }

    static let materialOptions = [
        "Bomull",
        "Ull",
        "Lin",
        "Silke",
        "Viskose",
        "Modal",
        "Lyocell",
        "Polyester",
        "Polyamid",
        "Akryl",
        "Elastan",
        "Acetat",
        "Annet",
        "Ukjent"
    ]

    static func newDraft(textileID: String) -> TextileMaterial {
        TextileMaterial(
            materialID: "MAT-\(UUID().uuidString.uppercased())",
            cloudRecordName: nil,
            textileID: textileID,
            material: "",
            percent: nil
        )
    }
}
