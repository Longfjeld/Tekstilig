#if os(macOS) && DEBUG
import CloudKit
import SwiftUI

@MainActor
struct DevelopmentIdentityReadDiagnosticView: View {
    // No CKContainer or transport is created by view/session initialization.
    @StateObject private var session = DevelopmentIdentityReadSession(
        makeSource: { SystemCloudKitEnvironmentEvidenceSource() },
        makeTransport: { expected in
            CloudKitIdentityDiagnosticTransport(
                container: CKContainer(identifier: CloudKitTextileRepository.containerIdentifier),
                zoneID: CKRecordZone.default().zoneID, expectedEnvironment: expected)
        })

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test 241 B.3 – isolert Development-lesing").font(.headline)
            Text("Eksplisitt lesing av privat database i iCloud.com.longfjeld.tekstilig, standardzone. Forventet miljø er låst til Development. Ingen bildeinnhold, eksport eller lagring.")
            HStack {
                Button("Les CloudKit Development-identiteter (kun lesing)") { session.start() }
                    .disabled(session.isRunning)
                Button("Avbryt lesing") { session.cancel() }
                    .disabled(!session.isRunning || session.cancellationRequested)
            }
            if session.isRunning {
                Text(session.cancellationRequested ? "Avbrudd bedt om – venter på at lesingen avsluttes …" : "Leser identiteter og metadata i to passeringer …")
            }
            ScrollView {
                Text(session.report).font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(minWidth: 720, minHeight: 520)
        .onDisappear { session.cancel() }
    }
}
#endif
