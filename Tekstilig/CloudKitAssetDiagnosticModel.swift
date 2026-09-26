import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class CloudKitAssetDiagnosticModel {
    static let containerIdentifier = "iCloud.com.longfjeld.tekstilig"
    static let textileRecordName = "swiftui-poc-textile-v1"
    static let imageRecordName = "swiftui-poc-textile-image-v1"

    private(set) var isRunning = false
    private(set) var completedSuccessfully = false

    private(set) var selectedImageData: Data?
    private(set) var fetchedImageData: Data?
    private(set) var selectedFileName = "–"
    private(set) var selectedContentType = "–"
    private(set) var selectedByteCount = 0
    private(set) var fetchedByteCount = 0
    private(set) var imageRecordName = "–"
    private(set) var logEntries: [AssetDiagnosticLogEntry] = []

    private var selectedFileExtension = "bin"

    private let container: CKContainer
    private let database: CKDatabase

    init() {
        container = CKContainer(identifier: Self.containerIdentifier)
        database = container.privateCloudDatabase
    }

    var hasSelectedImage: Bool {
        selectedImageData != nil
    }

    func setSelectedImage(
        data: Data,
        contentType: String,
        fileExtension: String
    ) {
        selectedImageData = data
        fetchedImageData = nil
        selectedContentType = contentType
        selectedFileExtension = Self.safeFileExtension(fileExtension)
        selectedFileName = "swiftui-asset-test.\(selectedFileExtension)"
        selectedByteCount = data.count
        fetchedByteCount = 0
        imageRecordName = "–"
        completedSuccessfully = false
        logEntries = [
            AssetDiagnosticLogEntry(
                message: "Testbilde valgt lokalt: \(selectedFileName) (\(Self.formatBytes(data.count))).",
                isError: false
            )
        ]
    }

    func setSelectionError(_ error: Error) {
        selectedImageData = nil
        fetchedImageData = nil
        selectedFileName = "–"
        selectedContentType = "–"
        selectedByteCount = 0
        fetchedByteCount = 0
        imageRecordName = "–"
        completedSuccessfully = false
        logEntries = [
            AssetDiagnosticLogEntry(
                message: "FEIL ved lesing av valgt bilde: \(error.localizedDescription)",
                isError: true
            )
        ]
    }

    func run() async {
        guard !isRunning else { return }
        guard let selectedImageData else {
            log("FEIL: Velg et testbilde før CKAsset-testen kjøres.", isError: true)
            return
        }

        isRunning = true
        completedSuccessfully = false
        fetchedImageData = nil
        fetchedByteCount = 0
        imageRecordName = "–"

        // Behold første linje som dokumenterer hvilket lokalt bilde som testes.
        logEntries = [
            AssetDiagnosticLogEntry(
                message: "Testbilde klart: \(selectedFileName) (\(Self.formatBytes(selectedImageData.count))).",
                isError: false
            )
        ]

        do {
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                throw AssetDiagnosticError.iCloudUnavailable(Self.description(for: accountStatus))
            }
            log("1. iCloud-konto og privat CloudKit-database er tilgjengelig.")

            let textileRecordID = CKRecord.ID(recordName: Self.textileRecordName)
            let textileRecord = try await database.record(for: textileRecordID)
            guard textileRecord.recordType == "Textile" else {
                throw AssetDiagnosticError.unexpectedRecordType(
                    expected: "Textile",
                    actual: textileRecord.recordType
                )
            }

            let textileID = textileRecord["textileId"] as? String ?? "T-SWIFTUI-POC-001"
            log("2. Test-Textile funnet: \(Self.textileRecordName).")

            let temporaryFileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("tekstilig-\(UUID().uuidString)")
                .appendingPathExtension(selectedFileExtension)

            try selectedImageData.write(to: temporaryFileURL, options: .atomic)
            defer {
                try? FileManager.default.removeItem(at: temporaryFileURL)
            }

            log("3. Midlertidig lokal bildefil skrevet for CKAsset.")

            let imageRecordID = CKRecord.ID(recordName: Self.imageRecordName)
            var imageRecord: CKRecord

            do {
                imageRecord = try await database.record(for: imageRecordID)
                guard imageRecord.recordType == "TextileImage" else {
                    throw AssetDiagnosticError.unexpectedRecordType(
                        expected: "TextileImage",
                        actual: imageRecord.recordType
                    )
                }
            } catch let error as CKError where error.code == .unknownItem {
                imageRecord = CKRecord(recordType: "TextileImage", recordID: imageRecordID)
            }

            imageRecord["imageId"] = "IMG-SWIFTUI-POC-001" as CKRecordValue
            imageRecord["textileId"] = textileID as CKRecordValue
            imageRecord["type"] = "fabric" as CKRecordValue
            imageRecord["primary"] = NSNumber(value: 1)
            imageRecord["fileName"] = selectedFileName as CKRecordValue
            imageRecord["contentType"] = selectedContentType as CKRecordValue
            imageRecord["imageAsset"] = CKAsset(fileURL: temporaryFileURL)

            let savedRecord = try await database.save(imageRecord)
            imageRecordName = savedRecord.recordID.recordName
            log("4. TextileImage og CKAsset ble lagret i privat Development-database.")

            let fetchedRecord = try await database.record(for: savedRecord.recordID)
            guard fetchedRecord.recordType == "TextileImage" else {
                throw AssetDiagnosticError.unexpectedRecordType(
                    expected: "TextileImage",
                    actual: fetchedRecord.recordType
                )
            }
            log("5. Samme TextileImage ble lest tilbake fra CloudKit.")

            guard let asset = fetchedRecord["imageAsset"] as? CKAsset else {
                throw AssetDiagnosticError.missingAsset
            }
            guard let fetchedFileURL = asset.fileURL else {
                throw AssetDiagnosticError.missingAssetFileURL
            }

            // CloudKit kan rydde staging-filen senere. Les derfor dataene umiddelbart.
            let downloadedData = try Data(contentsOf: fetchedFileURL)
            guard !downloadedData.isEmpty else {
                throw AssetDiagnosticError.emptyAsset
            }

            fetchedImageData = downloadedData
            fetchedByteCount = downloadedData.count
            log("6. CKAsset-filen ble lest lokalt igjen (\(Self.formatBytes(downloadedData.count))).")

            guard downloadedData == selectedImageData else {
                throw AssetDiagnosticError.assetDataMismatch(
                    uploadedBytes: selectedImageData.count,
                    downloadedBytes: downloadedData.count
                )
            }

            log("7. Nedlastet Asset er byte-for-byte identisk med valgt testbilde.")
            log("Steg 7 er validert. Klar for kryssenhetstest i steg 8.")
            completedSuccessfully = true
        } catch {
            log("FEIL: \(Self.description(for: error))", isError: true)
        }

        isRunning = false
    }

    private func log(_ message: String, isError: Bool = false) {
        logEntries.append(AssetDiagnosticLogEntry(message: message, isError: isError))
    }

    private static func safeFileExtension(_ value: String) -> String {
        let filtered = value.lowercased().filter { $0.isLetter || $0.isNumber }
        return filtered.isEmpty ? "bin" : filtered
    }

    private static func formatBytes(_ byteCount: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
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
        if let diagnosticError = error as? AssetDiagnosticError {
            return diagnosticError.localizedDescription
        }

        if let cloudKitError = error as? CKError {
            return "CloudKit \(cloudKitError.code.rawValue): \(cloudKitError.localizedDescription)"
        }

        return error.localizedDescription
    }
}

struct AssetDiagnosticLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

private enum AssetDiagnosticError: LocalizedError {
    case iCloudUnavailable(String)
    case unexpectedRecordType(expected: String, actual: String)
    case missingAsset
    case missingAssetFileURL
    case emptyAsset
    case assetDataMismatch(uploadedBytes: Int, downloadedBytes: Int)

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable(let status):
            return "CKAsset kan ikke testes fordi iCloud-status er: \(status)."
        case .unexpectedRecordType(let expected, let actual):
            return "Forventet record type \(expected), men fikk \(actual)."
        case .missingAsset:
            return "TextileImage-recorden inneholder ikke feltet imageAsset som CKAsset."
        case .missingAssetFileURL:
            return "CloudKit returnerte CKAsset uten tilgjengelig fileURL."
        case .emptyAsset:
            return "Den nedlastede CKAsset-filen er tom."
        case .assetDataMismatch(let uploadedBytes, let downloadedBytes):
            return "Asset-dataene avviker etter tur/retur. Valgt: \(uploadedBytes) byte, hentet: \(downloadedBytes) byte."
        }
    }
}
