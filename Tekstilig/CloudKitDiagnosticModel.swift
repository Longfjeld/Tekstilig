import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class CloudKitDiagnosticModel {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"
    static let testRecordName = "swiftui-poc-textile-v1"

    private(set) var isRunning = false
    private(set) var completedSuccessfully = false
    private(set) var accountStatusText = "Ikke kontrollert"
    private(set) var recordName = "–"
    private(set) var textileName = "–"
    private(set) var logEntries: [DiagnosticLogEntry] = []

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
        accountStatusText = "Kontrollerer …"
        recordName = "–"
        textileName = "–"
        logEntries.removeAll()

        log("1. CloudKit-container opprettet: \(Self.containerIdentifier)")

        do {
            let status = try await container.accountStatus()
            accountStatusText = Self.description(for: status)
            log("2. iCloud account status: \(accountStatusText)")

            guard status == .available else {
                throw DiagnosticError.iCloudUnavailable(accountStatusText)
            }

            log("3. Privat CloudKit-database er valgt.")

            let recordID = CKRecord.ID(recordName: Self.testRecordName)
            let savedRecord: CKRecord

            do {
                savedRecord = try await database.record(for: recordID)
                log("4. Eksisterende Textile funnet. Ingen ny testrecord ble opprettet.")
            } catch let error as CKError where error.code == .unknownItem {
                let record = CKRecord(recordType: "Textile", recordID: recordID)
                let now = Date()

                record["textileId"] = "T-SWIFTUI-POC-001" as CKRecordValue
                record["name"] = "SwiftUI CloudKit-test" as CKRecordValue
                record["category"] = "Test" as CKRecordValue
                record["createdAt"] = now as CKRecordValue
                record["updatedAt"] = now as CKRecordValue
                record["schemaVersion"] = 1 as CKRecordValue

                savedRecord = try await database.save(record)
                log("4. Minimal Textile ble opprettet og lagret.")
            }

            let fetchedRecord = try await database.record(for: savedRecord.recordID)
            guard fetchedRecord.recordType == "Textile" else {
                throw DiagnosticError.unexpectedRecordType(fetchedRecord.recordType)
            }

            recordName = fetchedRecord.recordID.recordName
            textileName = fetchedRecord["name"] as? String ?? "(navn mangler)"

            log("5. Textile ble lest tilbake fra CloudKit.")
            log("Record name: \(recordName)")
            log("Textile.name: \(textileName)")
            log("Steg 6 er validert. Klar for CKAsset-testen i steg 7.")

            completedSuccessfully = true
        } catch {
            log("FEIL: \(Self.description(for: error))", isError: true)
        }

        isRunning = false
    }

    private func log(_ message: String, isError: Bool = false) {
        logEntries.append(DiagnosticLogEntry(message: message, isError: isError))
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
        if let diagnosticError = error as? DiagnosticError {
            return diagnosticError.localizedDescription
        }

        if let cloudKitError = error as? CKError {
            return "CloudKit \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }

        return error.localizedDescription
    }
}

struct DiagnosticLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

private enum DiagnosticError: LocalizedError {
    case iCloudUnavailable(String)
    case unexpectedRecordType(String)

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable(let status):
            return "Privat CloudKit-database kan ikke testes fordi iCloud-status er: \(status)."
        case .unexpectedRecordType(let type):
            return "Forventet record type Textile, men fikk \(type)."
        }
    }
}
