import Foundation

struct Piece: Identifiable, Hashable {
    var pieceID: String
    var cloudRecordName: String?
    var textileID: String
    var lengthCm: Int64
    var widthCm: Int64
    var reservedLengthCm: Int64
    var project: String

    var id: String {
        cloudRecordName ?? pieceID
    }

    var availableLengthCm: Int64 {
        max(0, lengthCm - reservedLengthCm)
    }

    var isReserved: Bool {
        reservedLengthCm > 0
    }

    static func newDraft(textileID: String) -> Piece {
        Piece(
            pieceID: "P-\(UUID().uuidString.uppercased())",
            cloudRecordName: nil,
            textileID: textileID,
            lengthCm: 0,
            widthCm: 0,
            reservedLengthCm: 0,
            project: ""
        )
    }
}
