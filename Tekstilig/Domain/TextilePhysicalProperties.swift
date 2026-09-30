import Foundation

struct TextileStretch: Hashable {
    var level: String
    var direction: String
    var percent: Int?

    static let empty = TextileStretch(
        level: "",
        direction: "",
        percent: nil
    )

    var isEmpty: Bool {
        level.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        direction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        percent == nil
    }

    func normalized() -> TextileStretch {
        var result = self
        result.level = level.trimmingCharacters(in: .whitespacesAndNewlines)
        result.direction = direction.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.level.isEmpty {
            result.direction = ""
            result.percent = nil
        } else if result.level == "none" {
            result.direction = "notApplicable"
            result.percent = nil
        }

        return result
    }
}

struct TextileShrinkage: Hashable {
    var lengthPercent: Int?
    var widthPercent: Int?
    var note: String

    static let empty = TextileShrinkage(
        lengthPercent: nil,
        widthPercent: nil,
        note: ""
    )

    var isEmpty: Bool {
        lengthPercent == nil &&
        widthPercent == nil &&
        note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func normalized() -> TextileShrinkage {
        var result = self
        result.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
}

enum TextilePhysicalPropertyLabels {
    static func stretchLevel(_ value: String) -> String? {
        switch value {
        case "none": return "Ingen"
        case "low": return "Lav"
        case "medium": return "Middels"
        case "high": return "Høy"
        default: return nil
        }
    }

    static func stretchDirection(_ value: String) -> String? {
        switch value {
        case "length": return "Lengderetning"
        case "width": return "Bredderetning"
        case "both": return "Begge retninger"
        case "notApplicable": return "Ikke relevant"
        default: return nil
        }
    }
}
