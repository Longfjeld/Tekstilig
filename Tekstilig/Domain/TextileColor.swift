import Foundation

struct TextileColor: Identifiable, Hashable {
    var colorID: String
    var cloudRecordName: String?
    var textileID: String
    var group: String
    var name: String
    var hex: String

    var id: String {
        cloudRecordName ?? colorID
    }

    static let groupOptions = [
        "Hvit",
        "Beige/natur",
        "Gul",
        "Oransje",
        "Rød",
        "Rosa",
        "Lilla",
        "Blå",
        "Grønn",
        "Brun",
        "Grå",
        "Sort",
        "Flerfarget"
    ]

    static func newDraft(textileID: String) -> TextileColor {
        TextileColor(
            colorID: "COL-\(UUID().uuidString.uppercased())",
            cloudRecordName: nil,
            textileID: textileID,
            group: "",
            name: "",
            hex: ""
        )
    }
}
