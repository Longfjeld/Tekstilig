import SwiftUI

struct ContentView: View {
    @State private var diagnostic = CloudKitDiagnosticModel()

    var body: some View {
        NavigationStack {
            List {
                Section("CloudKit") {
                    LabeledContent("Container", value: CloudKitDiagnosticModel.containerIdentifier)
                    LabeledContent("Database", value: "Private / Development")
                    LabeledContent("iCloud", value: diagnostic.accountStatusText)
                }

                Section("Testrecord") {
                    LabeledContent("Record name", value: diagnostic.recordName)
                    LabeledContent("Textile.name", value: diagnostic.textileName)
                }

                Section {
                    Button {
                        Task {
                            await diagnostic.run()
                        }
                    } label: {
                        if diagnostic.isRunning {
                            HStack {
                                ProgressView()
                                Text("Kjører diagnostikk …")
                            }
                        } else {
                            Text("Kjør CloudKit-diagnostikk")
                        }
                    }
                    .disabled(diagnostic.isRunning)
                } footer: {
                    Text("Testen bruker én fast Development-record og oppretter derfor ikke en ny Textile for hver kjøring.")
                }

                if !diagnostic.logEntries.isEmpty {
                    Section("Resultat") {
                        ForEach(diagnostic.logEntries) { entry in
                            Label {
                                Text(entry.message)
                                    .font(.callout)
                            } icon: {
                                Image(systemName: entry.isError ? "xmark.circle.fill" : "checkmark.circle")
                                    .foregroundStyle(entry.isError ? .red : .secondary)
                            }
                        }
                    }
                }

                if diagnostic.completedSuccessfully {
                    Section {
                        Label("Steg 6 er fullført", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } footer: {
                        Text("Neste kodeleveranse er steg 7: TextileImage + CKAsset.")
                    }
                }
            }
            .navigationTitle("Tekstilig")
        }
    }
}

#Preview {
    ContentView()
}
