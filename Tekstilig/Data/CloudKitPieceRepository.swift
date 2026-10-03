import CloudKit
import Foundation

@MainActor
final class CloudKitPieceRepository: PieceRepository {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"

    private static let recordType = "Piece"
    private static let diagnosticRecordNames: Set<String> = [
        "swiftui-poc-piece-v1"
    ]

    private let database: CKDatabase

    init(container: CKContainer? = nil) {
        let resolvedContainer = container ?? CKContainer(identifier: Self.containerIdentifier)
        database = resolvedContainer.privateCloudDatabase
    }

    func fetchPieces(textileID: String) async throws -> [Piece] {
        let normalizedTextileID = textileID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTextileID.isEmpty else {
            throw CloudKitPieceRepositoryError.missingRequiredField("textileId")
        }

        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(format: "textileId == %@", normalizedTextileID)
        )

        let desiredKeys = [
            "pieceId",
            "textileId",
            "lengthCm",
            "widthCm",
            "reservedLengthCm",
            "project"
        ]

        var pieces: [Piece] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let response: (
                matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
                queryCursor: CKQueryOperation.Cursor?
            )

            if let cursor {
                response = try await database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: desiredKeys,
                    resultsLimit: 200
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: desiredKeys,
                    resultsLimit: 200
                )
            }

            for (_, result) in response.matchResults {
                switch result {
                case .success(let record):
                    guard !Self.diagnosticRecordNames.contains(record.recordID.recordName) else {
                        continue
                    }
                    pieces.append(try Self.piece(from: record))

                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return pieces.sorted {
            if $0.lengthCm != $1.lengthCm {
                return $0.lengthCm > $1.lengthCm
            }
            if $0.widthCm != $1.widthCm {
                return $0.widthCm > $1.widthCm
            }
            return $0.pieceID.localizedCaseInsensitiveCompare($1.pieceID) == .orderedAscending
        }
    }

    func fetchAllPieces() async throws -> [Piece] {
        let query = CKQuery(
            recordType: Self.recordType,
            predicate: NSPredicate(value: true)
        )

        let desiredKeys = [
            "pieceId",
            "textileId",
            "lengthCm",
            "widthCm",
            "reservedLengthCm",
            "project"
        ]

        var pieces: [Piece] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let response: (
                matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
                queryCursor: CKQueryOperation.Cursor?
            )

            if let cursor {
                response = try await database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: desiredKeys,
                    resultsLimit: 200
                )
            } else {
                response = try await database.records(
                    matching: query,
                    inZoneWith: nil,
                    desiredKeys: desiredKeys,
                    resultsLimit: 200
                )
            }

            for (_, result) in response.matchResults {
                switch result {
                case .success(let record):
                    guard !Self.diagnosticRecordNames.contains(record.recordID.recordName) else {
                        continue
                    }
                    pieces.append(try Self.piece(from: record))

                case .failure(let error):
                    throw error
                }
            }

            cursor = response.queryCursor
        } while cursor != nil

        return pieces.sorted {
            if $0.textileID != $1.textileID {
                return $0.textileID.localizedCaseInsensitiveCompare($1.textileID) == .orderedAscending
            }
            if $0.availableLengthCm != $1.availableLengthCm {
                return $0.availableLengthCm > $1.availableLengthCm
            }
            if $0.widthCm != $1.widthCm {
                return $0.widthCm > $1.widthCm
            }
            return $0.pieceID.localizedCaseInsensitiveCompare($1.pieceID) == .orderedAscending
        }
    }

    func save(_ piece: Piece) async throws -> Piece {
        try Self.validate(piece)

        let record: CKRecord

        if let cloudRecordName = piece.cloudRecordName {
            record = try await database.record(
                for: CKRecord.ID(recordName: cloudRecordName)
            )

            guard record.recordType == Self.recordType else {
                throw CloudKitPieceRepositoryError.unexpectedRecordType(record.recordType)
            }
        } else {
            record = CKRecord(recordType: Self.recordType)
        }

        record["pieceId"] = piece.pieceID as CKRecordValue
        record["textileId"] = piece.textileID as CKRecordValue
        record["lengthCm"] = NSNumber(value: piece.lengthCm)
        record["widthCm"] = NSNumber(value: piece.widthCm)
        record["reservedLengthCm"] = NSNumber(value: piece.reservedLengthCm)
        record["project"] = piece.project as CKRecordValue

        let savedRecord = try await database.save(record)
        return try Self.piece(from: savedRecord)
    }

    func delete(_ piece: Piece) async throws {
        guard let cloudRecordName = piece.cloudRecordName else {
            throw CloudKitPieceRepositoryError.cannotDeleteUnsavedPiece
        }

        _ = try await database.deleteRecord(
            withID: CKRecord.ID(recordName: cloudRecordName)
        )
    }

    private static func piece(from record: CKRecord) throws -> Piece {
        guard record.recordType == recordType else {
            throw CloudKitPieceRepositoryError.unexpectedRecordType(record.recordType)
        }

        guard let pieceID = record["pieceId"] as? String,
              !pieceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitPieceRepositoryError.missingRequiredField("pieceId")
        }

        guard let textileID = record["textileId"] as? String,
              !textileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitPieceRepositoryError.missingRequiredField("textileId")
        }

        let lengthCm = int64Value(record["lengthCm"])
        let widthCm = int64Value(record["widthCm"])
        let reservedLengthCm = int64Value(record["reservedLengthCm"])
        let project = record["project"] as? String ?? ""

        let piece = Piece(
            pieceID: pieceID,
            cloudRecordName: record.recordID.recordName,
            textileID: textileID,
            lengthCm: lengthCm,
            widthCm: widthCm,
            reservedLengthCm: reservedLengthCm,
            project: project
        )

        try validate(piece)
        return piece
    }

    private static func validate(_ piece: Piece) throws {
        guard !piece.pieceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitPieceRepositoryError.missingRequiredField("pieceId")
        }
        guard !piece.textileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudKitPieceRepositoryError.missingRequiredField("textileId")
        }
        guard piece.lengthCm > 0 else {
            throw CloudKitPieceRepositoryError.invalidLength
        }
        guard piece.widthCm > 0 else {
            throw CloudKitPieceRepositoryError.invalidWidth
        }
        guard piece.reservedLengthCm >= 0,
              piece.reservedLengthCm <= piece.lengthCm else {
            throw CloudKitPieceRepositoryError.invalidReservedLength
        }
        if piece.reservedLengthCm > 0,
           piece.project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CloudKitPieceRepositoryError.projectRequiredForReservation
        }
    }

    private static func int64Value(_ value: CKRecordValue?) -> Int64 {
        (value as? NSNumber)?.int64Value ?? 0
    }
}

private enum CloudKitPieceRepositoryError: LocalizedError {
    case unexpectedRecordType(String)
    case missingRequiredField(String)
    case invalidLength
    case invalidWidth
    case invalidReservedLength
    case projectRequiredForReservation
    case cannotDeleteUnsavedPiece

    var errorDescription: String? {
        switch self {
        case .unexpectedRecordType(let actual):
            return "Forventet CloudKit record type Piece, men fikk \(actual)."
        case .missingRequiredField(let field):
            return "En Piece-record mangler det påkrevde feltet \(field)."
        case .invalidLength:
            return "Lengden må være større enn 0 cm."
        case .invalidWidth:
            return "Bredden må være større enn 0 cm."
        case .invalidReservedLength:
            return "Reservert lengde må være mellom 0 cm og stykkets totale lengde."
        case .projectRequiredForReservation:
            return "Prosjekt må fylles ut når en del av stykket er reservert."
        case .cannotDeleteUnsavedPiece:
            return "Et stoffstykke som ikke er lagret i CloudKit kan ikke slettes."
        }
    }
}
