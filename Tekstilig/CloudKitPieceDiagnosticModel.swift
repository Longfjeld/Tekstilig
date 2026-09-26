import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class CloudKitPieceDiagnosticModel {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"
    static let textileRecordName = "swiftui-poc-textile-v1"
    static let pieceRecordName = "swiftui-poc-piece-v1"

    static let pieceID = "P-SWIFTUI-POC-001"
    static let expectedLengthCm: Int64 = 280
    static let expectedWidthCm: Int64 = 145
    static let expectedReservedLengthCm: Int64 = 150
    static let expectedProject = "SwiftUI testprosjekt"

    private(set) var isRunning = false
    private(set) var completedSuccessfully = false
    private(set) var recordName = "–"
    private(set) var textileID = "–"
    private(set) var lengthCm: Int64 = 0
    private(set) var widthCm: Int64 = 0
    private(set) var reservedLengthCm: Int64 = 0
    private(set) var project = "–"
    private(set) var logEntries: [PieceDiagnosticLogEntry] = []

    private let container: CKContainer
    private let database: CKDatabase

    init() {
        container = CKContainer(identifier: Self.containerIdentifier)
        database = container.privateCloudDatabase
    }

    func run() async {
        guard !isRunning else { return }

        isRunning = true
        completedSuccessfully = false
        recordName = "–"
        textileID = "–"
        lengthCm = 0
        widthCm = 0
        reservedLengthCm = 0
        project = "–"
        logEntries.removeAll()

        do {
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                throw PieceDiagnosticError.iCloudUnavailable(Self.description(for: accountStatus))
            }
            log("1. iCloud-konto og privat CloudKit-database er tilgjengelig.")

            let textileRecordID = CKRecord.ID(recordName: Self.textileRecordName)
            let textileRecord = try await database.record(for: textileRecordID)
            guard textileRecord.recordType == "Textile" else {
                throw PieceDiagnosticError.unexpectedRecordType(
                    expected: "Textile",
                    actual: textileRecord.recordType
                )
            }

            guard let parentTextileID = textileRecord["textileId"] as? String,
                  !parentTextileID.isEmpty else {
                throw PieceDiagnosticError.missingTextileID
            }
            textileID = parentTextileID
            log("2. Test-Textile funnet med textileId: \(parentTextileID).")

            let pieceRecordID = CKRecord.ID(recordName: Self.pieceRecordName)
            let pieceRecord: CKRecord

            do {
                let existingRecord = try await database.record(for: pieceRecordID)
                guard existingRecord.recordType == "Piece" else {
                    throw PieceDiagnosticError.unexpectedRecordType(
                        expected: "Piece",
                        actual: existingRecord.recordType
                    )
                }
                pieceRecord = existingRecord
                log("3. Eksisterende Piece-testrecord funnet og gjenbrukes.")
            } catch let error as CKError where error.code == .unknownItem {
                pieceRecord = CKRecord(recordType: "Piece", recordID: pieceRecordID)
                log("3. Ingen eksisterende Piece-testrecord funnet; en ny opprettes.")
            }

            pieceRecord["pieceId"] = Self.pieceID as CKRecordValue
            pieceRecord["textileId"] = parentTextileID as CKRecordValue
            pieceRecord["lengthCm"] = NSNumber(value: Self.expectedLengthCm)
            pieceRecord["widthCm"] = NSNumber(value: Self.expectedWidthCm)
            pieceRecord["reservedLengthCm"] = NSNumber(value: 0)
            pieceRecord["project"] = "" as CKRecordValue

            let savedRecord = try await database.save(pieceRecord)
            recordName = savedRecord.recordID.recordName
            log("4. Piece ble lagret med lengde, bredde og kobling til Textile.")

            let fetchedBaseRecord = try await database.record(for: savedRecord.recordID)
            try Self.validate(
                record: fetchedBaseRecord,
                textileID: parentTextileID,
                reservedLengthCm: 0,
                project: ""
            )
            log("5. Piece ble lest tilbake, og basisfeltene er korrekte.")

            fetchedBaseRecord["reservedLengthCm"] = NSNumber(value: Self.expectedReservedLengthCm)
            fetchedBaseRecord["project"] = Self.expectedProject as CKRecordValue

            let updatedRecord = try await database.save(fetchedBaseRecord)
            log("6. Reservasjon ble lagt til på samme Piece-record.")

            let fetchedUpdatedRecord = try await database.record(for: updatedRecord.recordID)
            try Self.validate(
                record: fetchedUpdatedRecord,
                textileID: parentTextileID,
                reservedLengthCm: Self.expectedReservedLengthCm,
                project: Self.expectedProject
            )

            recordName = fetchedUpdatedRecord.recordID.recordName
            textileID = fetchedUpdatedRecord["textileId"] as? String ?? "–"
            lengthCm = Self.int64Value(fetchedUpdatedRecord["lengthCm"])
            widthCm = Self.int64Value(fetchedUpdatedRecord["widthCm"])
            reservedLengthCm = Self.int64Value(fetchedUpdatedRecord["reservedLengthCm"])
            project = fetchedUpdatedRecord["project"] as? String ?? "–"

            log("7. Oppdatert Piece ble lest tilbake med korrekt reservasjon.")
            log("8. Piece-relasjonen og alle testede felt er validert.")
            log("Steg 9 er validert. Native CloudKit-PoC-en har nå validert Textile, TextileImage/CKAsset og Piece.")
            completedSuccessfully = true
        } catch {
            log("FEIL: \(Self.description(for: error))", isError: true)
        }

        isRunning = false
    }

    private func log(_ message: String, isError: Bool = false) {
        logEntries.append(PieceDiagnosticLogEntry(message: message, isError: isError))
    }

    private static func validate(
        record: CKRecord,
        textileID expectedTextileID: String,
        reservedLengthCm expectedReservedLengthCm: Int64,
        project expectedProject: String
    ) throws {
        guard record.recordType == "Piece" else {
            throw PieceDiagnosticError.unexpectedRecordType(expected: "Piece", actual: record.recordType)
        }

        let actualPieceID = record["pieceId"] as? String
        let actualTextileID = record["textileId"] as? String
        let actualLengthCm = int64Value(record["lengthCm"])
        let actualWidthCm = int64Value(record["widthCm"])
        let actualReservedLengthCm = int64Value(record["reservedLengthCm"])
        let actualProject = record["project"] as? String ?? ""

        guard actualPieceID == Self.pieceID else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "pieceId",
                expected: Self.pieceID,
                actual: actualPieceID ?? "nil"
            )
        }
        guard actualTextileID == expectedTextileID else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "textileId",
                expected: expectedTextileID,
                actual: actualTextileID ?? "nil"
            )
        }
        guard actualLengthCm == Self.expectedLengthCm else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "lengthCm",
                expected: String(Self.expectedLengthCm),
                actual: String(actualLengthCm)
            )
        }
        guard actualWidthCm == Self.expectedWidthCm else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "widthCm",
                expected: String(Self.expectedWidthCm),
                actual: String(actualWidthCm)
            )
        }
        guard actualReservedLengthCm == expectedReservedLengthCm else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "reservedLengthCm",
                expected: String(expectedReservedLengthCm),
                actual: String(actualReservedLengthCm)
            )
        }
        guard actualProject == expectedProject else {
            throw PieceDiagnosticError.fieldMismatch(
                field: "project",
                expected: expectedProject,
                actual: actualProject
            )
        }
    }

    private static func int64Value(_ value: CKRecordValue?) -> Int64 {
        (value as? NSNumber)?.int64Value ?? 0
    }

    private static func description(for status: CKAccountStatus) -> String {
        switch status {
        case .available:
            return "Tilgjengelig"
        case .noAccount:
            return "Ingen iCloud-konto"
        case .restricted:
            return "Begrenset"
        case .couldNotDetermine:
            return "Kunne ikke avgjøres"
        case .temporarilyUnavailable:
            return "Midlertidig utilgjengelig"
        @unknown default:
            return "Ukjent status"
        }
    }

    private static func description(for error: Error) -> String {
        if let diagnosticError = error as? PieceDiagnosticError {
            return diagnosticError.localizedDescription
        }

        if let cloudKitError = error as? CKError {
            return "CloudKit \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }

        return error.localizedDescription
    }
}

struct PieceDiagnosticLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

private enum PieceDiagnosticError: LocalizedError {
    case iCloudUnavailable(String)
    case unexpectedRecordType(expected: String, actual: String)
    case missingTextileID
    case fieldMismatch(field: String, expected: String, actual: String)

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable(let status):
            return "Piece kan ikke testes fordi iCloud-status er: \(status)."
        case .unexpectedRecordType(let expected, let actual):
            return "Forventet record type \(expected), men fikk \(actual)."
        case .missingTextileID:
            return "Test-Textile mangler textileId og kan derfor ikke brukes som forelder for Piece."
        case .fieldMismatch(let field, let expected, let actual):
            return "Feltet \(field) avviker. Forventet \(expected), fikk \(actual)."
        }
    }
}
