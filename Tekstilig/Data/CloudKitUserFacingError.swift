import CloudKit
import Foundation

struct CloudKitUserFacingError: Equatable, Sendable {
    let title: String
    let message: String

    static func describe(_ error: Error, fallbackTitle: String) -> CloudKitUserFacingError {
        guard let cloudKitError = error as? CKError else {
            return CloudKitUserFacingError(
                title: fallbackTitle,
                message: error.localizedDescription
            )
        }

        switch cloudKitError.code {
        case .notAuthenticated:
            return CloudKitUserFacingError(
                title: "iCloud er ikke tilgjengelig",
                message: "Kontroller at du er logget inn på iCloud og at iCloud Drive er slått på, og prøv deretter igjen."
            )

        case .networkUnavailable, .networkFailure:
            return CloudKitUserFacingError(
                title: "Ingen forbindelse til iCloud",
                message: "Kontroller nettverkstilkoblingen og prøv igjen."
            )

        case .serviceUnavailable, .zoneBusy, .requestRateLimited:
            var message = "iCloud er midlertidig utilgjengelig. Vent litt og prøv igjen."
            if let retryAfterSeconds = cloudKitError.retryAfterSeconds {
                message += " Prøv igjen om ca. \(Int(retryAfterSeconds.rounded(.up))) sekunder."
            }
            return CloudKitUserFacingError(
                title: "iCloud er midlertidig utilgjengelig",
                message: message
            )

        case .quotaExceeded:
            return CloudKitUserFacingError(
                title: "iCloud-lagringen er full",
                message: "Frigjør plass i iCloud og prøv igjen."
            )

        case .permissionFailure:
            return CloudKitUserFacingError(
                title: "Ingen tilgang til iCloud-data",
                message: "Tekstilig fikk ikke tilgang til den private iCloud-databasen. Kontroller iCloud-innstillingene og prøv igjen."
            )

        default:
            return CloudKitUserFacingError(
                title: fallbackTitle,
                message: "Tekstilig fikk ikke kontakt med iCloud-dataene. Prøv igjen. Hvis problemet fortsetter, kontroller iCloud- og nettverksinnstillingene."
            )
        }
    }
}
