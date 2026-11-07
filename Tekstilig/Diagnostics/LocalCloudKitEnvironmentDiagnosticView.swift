#if os(macOS) && DEBUG
import SwiftUI

// Isolated app root: no library, repositories, transport, files or automatic work.
@MainActor
struct LocalCloudKitEnvironmentDiagnosticView: View {
    private typealias E = CloudKitEnvironmentVerification
    @State private var expectedEnvironment: E.Environment?
    @State private var outcome: E.Outcome?

    var body: some View {
        Form {
            Section("Test 241 B.2 – isolert lokal miljøkontroll") {
                Text("Bare lokal signatur og entitlement. Ingen CloudKit-oppslag utføres av denne kontrollen. Ingen skrivetillatelse.")
                Picker("Forventet CloudKit-miljø", selection: $expectedEnvironment) {
                    Text("Velg eksplisitt …").tag(E.Environment?.none)
                    Text("Development").tag(E.Environment?.some(.development))
                    Text("Production").tag(E.Environment?.some(.production))
                }
                LabeledContent("Forventet miljø", value: expectedEnvironment?.rawValue ?? "Ikke valgt")
                Button("Kontroller lokalt signert CloudKit-miljø") {
                    outcome = E.evaluate(source: SystemCloudKitEnvironmentEvidenceSource(), expected: expectedEnvironment)
                }
            }
            Section("Resultat") {
                if let outcome {
                    Text(resultText(outcome))
                        .textSelection(.enabled)
                    Text(evidenceText(outcome))
                } else {
                    Text("Ikke kontrollert. Valg av miljø starter ingen kontroll.")
                }
            }
            Section("Lokal beviskilde og begrensning") {
                Text("Metode: signaturen til kjørende prosess og entitlement \(E.entitlementKey).")
                    .textSelection(.enabled)
                Text("Planlagt API-kjede: SecCodeCopySelf → SecCodeCheckValidity → SecTaskCreateFromSelf → SecTaskCopyValueForEntitlement. Kjeden stopper ved første feil.")
                Text("Metodebeskrivelsen er ikke et vellykket bevis. Resultatet ovenfor viser om kontrollen faktisk lyktes. Ingen konto, container, database eller server er verifisert.")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 640, minHeight: 520)
        .onChange(of: expectedEnvironment) { _, _ in outcome = nil }
    }

    private func resultText(_ outcome: E.Outcome) -> String {
        switch outcome {
        case .verified(let environment):
            return "Verifisert lokalt miljø: \(environment.rawValue). Samsvarer med forventet miljø."
        case .mismatch(let expected, let observed):
            return "STOPP – miljøavvik. Forventet: \(expected.rawValue). Verifisert lokalt miljø: \(observed.rawValue)."
        case .unverified(let reason):
            return "STOPP – uverifisert miljø. \(reasonText(reason))"
        }
    }

    private func evidenceText(_ outcome: E.Outcome) -> String {
        switch outcome {
        case .verified, .mismatch:
            return "Bevis: lokal prosessignatur validert; eksakt CloudKit-miljøentitlement lest fra gjeldende task. Hele API-kjeden lyktes. Dette er ikke serverattestasjon."
        case .unverified:
            return "Bevis: utilstrekkelig eller ugyldig lokalt grunnlag. Ingen verifisert miljøverdi; se STOPP-årsak."
        }
    }

    private func reasonText(_ reason: E.Reason) -> String {
        switch reason {
        case .missingExpectedEnvironment: return "Forventet miljø er ikke valgt; ingen bevisoppslag utført."
        case .unsupportedPlatform: return "Plattformen støtter ikke denne beviskilden."
        case .codeLookupFailed(let status): return "SecCodeCopySelf feilet (OSStatus \(status)); signatur og entitlement er ikke kontrollert."
        case .signatureInvalid(let status): return "SecCodeCheckValidity feilet (OSStatus \(status)); entitlement er ikke lest."
        case .taskUnavailable: return "Signaturen er validert, men SecTaskCreateFromSelf ga ingen task; entitlement er ikke lest."
        case .missingEntitlement: return "Signaturen er validert, men CloudKit-miljøentitlement mangler."
        case .invalidType(let type): return "Signaturen er validert, men entitlement har feil datatype: \(type)."
        case .unknownValue(let value): return "Signaturen er validert, men entitlement har ukjent verdi: \(String(reflecting: value))."
        case .entitlementError(let error): return "Signaturen er validert, men entitlement kunne ikke leses: \(error)."
        }
    }
}
#endif
