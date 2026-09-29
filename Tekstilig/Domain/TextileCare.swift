import Foundation

struct TextileCare: Hashable {
    var washAllowed: Bool?
    var washTemperatureC: Int?
    var washCycle: String
    var bleach: String
    var tumbleDry: String
    var drying: String
    var iron: String
    var dryClean: String
    var notes: String

    static let empty = TextileCare(
        washAllowed: nil,
        washTemperatureC: nil,
        washCycle: "",
        bleach: "",
        tumbleDry: "",
        drying: "",
        iron: "",
        dryClean: "",
        notes: ""
    )

    var isEmpty: Bool {
        washAllowed == nil &&
        washTemperatureC == nil &&
        washCycle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        bleach.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        tumbleDry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        drying.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        iron.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        dryClean.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func normalized() -> TextileCare {
        var result = self
        result.washCycle = washCycle.trimmingCharacters(in: .whitespacesAndNewlines)
        result.bleach = bleach.trimmingCharacters(in: .whitespacesAndNewlines)
        result.tumbleDry = tumbleDry.trimmingCharacters(in: .whitespacesAndNewlines)
        result.drying = drying.trimmingCharacters(in: .whitespacesAndNewlines)
        result.iron = iron.trimmingCharacters(in: .whitespacesAndNewlines)
        result.dryClean = dryClean.trimmingCharacters(in: .whitespacesAndNewlines)
        result.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.washAllowed != true {
            result.washTemperatureC = nil
            result.washCycle = ""
        }

        return result
    }
}

enum TextileCareLabels {
    static func wash(_ care: TextileCare) -> String? {
        guard let allowed = care.washAllowed else { return nil }
        guard allowed else { return "Skal ikke vaskes" }

        var parts: [String] = []
        if let temperature = care.washTemperatureC {
            parts.append("\(temperature) °C")
        }
        if let cycle = washCycle(care.washCycle) {
            parts.append(cycle)
        }
        return parts.isEmpty ? "Vask tillatt" : parts.joined(separator: " · ")
    }

    static func washCycle(_ value: String) -> String? {
        switch value {
        case "normal": return "Normalprogram"
        case "gentle": return "Skånsomt program"
        case "veryGentle": return "Svært skånsomt program"
        default: return nil
        }
    }

    static func bleach(_ value: String) -> String? {
        switch value {
        case "allowed": return "Bleking tillatt"
        case "nonChlorine": return "Kun oksygen-/klorfri bleking"
        case "notAllowed": return "Skal ikke blekes"
        default: return nil
        }
    }

    static func tumbleDry(_ value: String) -> String? {
        switch value {
        case "low": return "Tørketrommel, lav temperatur"
        case "normal": return "Tørketrommel, normal temperatur"
        case "notAllowed": return "Skal ikke tørketromles"
        default: return nil
        }
    }

    static func drying(_ value: String) -> String? {
        switch value {
        case "line": return "Hengetørkes"
        case "drip": return "Drypptørkes"
        case "flat": return "Flattørkes"
        case "shade": return "Tørkes i skyggen"
        default: return nil
        }
    }

    static func iron(_ value: String) -> String? {
        switch value {
        case "low": return "Strykes på lav temperatur"
        case "medium": return "Strykes på middels temperatur"
        case "high": return "Strykes på høy temperatur"
        case "notAllowed": return "Skal ikke strykes"
        default: return nil
        }
    }

    static func dryClean(_ value: String) -> String? {
        switch value {
        case "P": return "Profesjonell rens – P"
        case "F": return "Profesjonell rens – F"
        case "W": return "Profesjonell våtrens – W"
        case "notAllowed": return "Skal ikke renses"
        default: return nil
        }
    }
}
