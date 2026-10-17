import Foundation

struct TekstiligBackupDocument: Codable, Equatable {
    static let currentFormat = "tekstilig-backup"
    static let currentFormatVersion = 1

    var format: String
    var formatVersion: Int
    var exportedAt: Date
    var textiles: [TekstiligBackupTextile]
}

struct TekstiligBackupTextile: Codable, Equatable {
    var textileID: String
    var name: String
    var category: String
    var createdAt: Date
    var updatedAt: Date
    var schemaVersion: Int
    var locationArea: String
    var locationShelf: String
    var locationContainer: String
    var notes: String
    var care: TekstiligBackupCare
    var weightGsm: Int?
    var stretch: TekstiligBackupStretch
    var shrinkage: TekstiligBackupShrinkage
    var materials: [TekstiligBackupMaterial]
    var colors: [TekstiligBackupColor]
    var pieces: [TekstiligBackupPiece]
    var images: [TekstiligBackupImage]
}

struct TekstiligBackupCare: Codable, Equatable {
    var washAllowed: Bool?
    var washTemperatureC: Int?
    var washCycle: String
    var bleach: String
    var tumbleDry: String
    var drying: String
    var iron: String
    var dryClean: String
    var notes: String
}

struct TekstiligBackupStretch: Codable, Equatable {
    var level: String
    var direction: String
    var percent: Int?
}

struct TekstiligBackupShrinkage: Codable, Equatable {
    var lengthPercent: Int?
    var widthPercent: Int?
    var note: String
}

struct TekstiligBackupMaterial: Codable, Equatable {
    var materialID: String
    var material: String
    var percent: Int64?
}

struct TekstiligBackupColor: Codable, Equatable {
    var colorID: String
    var group: String
    var name: String
    var hex: String
}

struct TekstiligBackupPiece: Codable, Equatable {
    var pieceID: String
    var lengthCm: Int64
    var widthCm: Int64
    var reservedLengthCm: Int64
    var project: String
}

struct TekstiligBackupImage: Codable, Equatable {
    var imageID: String
    var type: String
    var isPrimary: Bool
    var fileName: String
    var contentType: String
    var backupPath: String
}

struct TekstiligBackupImageFile {
    var backupPath: String
    var data: Data
}

struct TekstiligBackupSnapshot {
    var document: TekstiligBackupDocument
    var imageFiles: [TekstiligBackupImageFile]
}
