import Foundation

struct TextileImage: Identifiable, Hashable {
    var imageID: String
    var cloudRecordName: String?
    var textileID: String
    var type: String
    var isPrimary: Bool
    var fileName: String
    var contentType: String

    var id: String {
        cloudRecordName ?? imageID
    }

    static func newPrimaryDraft(
        textileID: String,
        fileName: String,
        contentType: String
    ) -> TextileImage {
        TextileImage(
            imageID: "IMG-\(UUID().uuidString.uppercased())",
            cloudRecordName: nil,
            textileID: textileID,
            type: "fabric",
            isPrimary: true,
            fileName: fileName,
            contentType: contentType
        )
    }
}

struct TextileImageContent {
    var image: TextileImage
    var data: Data
}
