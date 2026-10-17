import Foundation

@MainActor
final class TekstiligBackupBuilder {
    private let textileRepository: any TextileRepository
    private let pieceRepository: any PieceRepository
    private let materialRepository: any TextileMaterialRepository
    private let colorRepository: any TextileColorRepository
    private let imageRepository: any TextileImageRepository

    init(
        textileRepository: any TextileRepository,
        pieceRepository: any PieceRepository,
        materialRepository: any TextileMaterialRepository,
        colorRepository: any TextileColorRepository,
        imageRepository: any TextileImageRepository
    ) {
        self.textileRepository = textileRepository
        self.pieceRepository = pieceRepository
        self.materialRepository = materialRepository
        self.colorRepository = colorRepository
        self.imageRepository = imageRepository
    }

    convenience init() {
        self.init(
            textileRepository: CloudKitTextileRepository(),
            pieceRepository: CloudKitPieceRepository(),
            materialRepository: CloudKitTextileMaterialRepository(),
            colorRepository: CloudKitTextileColorRepository(),
            imageRepository: CloudKitTextileImageRepository()
        )
    }

    func buildSnapshot(exportedAt: Date = Date()) async throws -> TekstiligBackupSnapshot {
        let textiles = try await textileRepository.fetchTextiles()
        let pieces = try await pieceRepository.fetchAllPieces()
        let materials = try await materialRepository.fetchAllMaterials()
        let colors = try await colorRepository.fetchAllColors()

        let piecesByTextile = Dictionary(grouping: pieces, by: \.textileID)
        let materialsByTextile = Dictionary(grouping: materials, by: \.textileID)
        let colorsByTextile = Dictionary(grouping: colors, by: \.textileID)

        var backupTextiles: [TekstiligBackupTextile] = []
        var imageFiles: [TekstiligBackupImageFile] = []

        for textile in textiles.sorted(by: Self.textileSort) {
            let imageContent = try await imageRepository.fetchPrimaryImage(textileID: textile.textileID)
            let image = imageContent.map(Self.backupImage)

            if let imageContent, let image {
                imageFiles.append(
                    TekstiligBackupImageFile(
                        backupPath: image.backupPath,
                        data: imageContent.data
                    )
                )
            }

            backupTextiles.append(
                Self.backupTextile(
                    textile,
                    pieces: piecesByTextile[textile.textileID] ?? [],
                    materials: materialsByTextile[textile.textileID] ?? [],
                    colors: colorsByTextile[textile.textileID] ?? [],
                    image: image
                )
            )
        }

        let document = TekstiligBackupDocument(
            format: TekstiligBackupDocument.currentFormat,
            formatVersion: TekstiligBackupDocument.currentFormatVersion,
            exportedAt: exportedAt,
            textiles: backupTextiles
        )

        return TekstiligBackupSnapshot(document: document, imageFiles: imageFiles)
    }

    func encodeDocument(_ document: TekstiligBackupDocument) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(TekstiligBackupDateCodec.string(from: date))
        }
        return try encoder.encode(document)
    }

    func decodeDocument(_ data: Data) throws -> TekstiligBackupDocument {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            guard let date = TekstiligBackupDateCodec.date(from: value) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Ugyldig ISO 8601-dato i Tekstilig-backup: \(value)"
                )
            }
            return date
        }
        return try decoder.decode(TekstiligBackupDocument.self, from: data)
    }

    private static func backupTextile(
        _ textile: Textile,
        pieces: [Piece],
        materials: [TextileMaterial],
        colors: [TextileColor],
        image: TekstiligBackupImage?
    ) -> TekstiligBackupTextile {
        TekstiligBackupTextile(
            textileID: textile.textileID,
            name: textile.name,
            category: textile.category,
            createdAt: textile.createdAt,
            updatedAt: textile.updatedAt,
            schemaVersion: textile.schemaVersion,
            locationArea: textile.locationArea,
            locationShelf: textile.locationShelf,
            locationContainer: textile.locationContainer,
            notes: textile.notes,
            care: TekstiligBackupCare(
                washAllowed: textile.care.washAllowed,
                washTemperatureC: textile.care.washTemperatureC,
                washCycle: textile.care.washCycle,
                bleach: textile.care.bleach,
                tumbleDry: textile.care.tumbleDry,
                drying: textile.care.drying,
                iron: textile.care.iron,
                dryClean: textile.care.dryClean,
                notes: textile.care.notes
            ),
            weightGsm: textile.weightGsm,
            stretch: TekstiligBackupStretch(
                level: textile.stretch.level,
                direction: textile.stretch.direction,
                percent: textile.stretch.percent
            ),
            shrinkage: TekstiligBackupShrinkage(
                lengthPercent: textile.shrinkage.lengthPercent,
                widthPercent: textile.shrinkage.widthPercent,
                note: textile.shrinkage.note
            ),
            materials: materials
                .sorted { $0.materialID.localizedCaseInsensitiveCompare($1.materialID) == .orderedAscending }
                .map {
                    TekstiligBackupMaterial(
                        materialID: $0.materialID,
                        material: $0.material,
                        percent: $0.percent
                    )
                },
            colors: colors
                .sorted { $0.colorID.localizedCaseInsensitiveCompare($1.colorID) == .orderedAscending }
                .map {
                    TekstiligBackupColor(
                        colorID: $0.colorID,
                        group: $0.group,
                        name: $0.name,
                        hex: $0.hex
                    )
                },
            pieces: pieces
                .sorted { $0.pieceID.localizedCaseInsensitiveCompare($1.pieceID) == .orderedAscending }
                .map {
                    TekstiligBackupPiece(
                        pieceID: $0.pieceID,
                        lengthCm: $0.lengthCm,
                        widthCm: $0.widthCm,
                        reservedLengthCm: $0.reservedLengthCm,
                        project: $0.project
                    )
                },
            images: image.map { [$0] } ?? []
        )
    }

    private static func backupImage(_ content: TextileImageContent) -> TekstiligBackupImage {
        let image = content.image
        return TekstiligBackupImage(
            imageID: image.imageID,
            type: image.type,
            isPrimary: image.isPrimary,
            fileName: image.fileName,
            contentType: image.contentType,
            backupPath: backupPath(for: image)
        )
    }

    private static func backupPath(for image: TextileImage) -> String {
        let originalExtension = URL(fileURLWithPath: image.fileName).pathExtension
        let safeExtension = originalExtension.isEmpty ? fallbackExtension(for: image.contentType) : originalExtension
        let suffix = safeExtension.isEmpty ? "" : ".\(safeExtension.lowercased())"
        return "images/\(image.imageID)\(suffix)"
    }

    private static func fallbackExtension(for contentType: String) -> String {
        switch contentType.lowercased() {
        case "image/jpeg", "image/jpg": return "jpg"
        case "image/png": return "png"
        case "image/heic", "image/heif": return "heic"
        default: return "img"
        }
    }

    private static func textileSort(_ lhs: Textile, _ rhs: Textile) -> Bool {
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt < rhs.createdAt
        }
        return lhs.textileID.localizedCaseInsensitiveCompare(rhs.textileID) == .orderedAscending
    }
}


private enum TekstiligBackupDateCodec {
    static func string(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    static func date(from value: String) -> Date? {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        fractionalFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: value)
    }
}
