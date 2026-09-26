import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var diagnostic = CloudKitAssetDiagnosticModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Forutsetning") {
                    Label("Steg 6: native CloudKit er validert", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)

                    LabeledContent("Container", value: CloudKitAssetDiagnosticModel.containerIdentifier)
                    LabeledContent("Database", value: "Private / Development")
                    LabeledContent("Textile", value: CloudKitAssetDiagnosticModel.textileRecordName)
                }

                Section("1. Velg testbilde") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Velg bilde fra Bilder", systemImage: "photo.on.rectangle")
                    }

                    if let data = diagnostic.selectedImageData {
                        DiagnosticImage(data: data)

                        LabeledContent("Fil", value: diagnostic.selectedFileName)
                        LabeledContent("Type", value: diagnostic.selectedContentType)
                        LabeledContent("Størrelse", value: byteCount(diagnostic.selectedByteCount))
                    } else {
                        Text("Velg ett lite bilde. For denne tekniske testen trenger vi ikke kamera i appen ennå.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
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
                                Text("Tester CKAsset …")
                            }
                        } else {
                            Label("Lagre og les CKAsset", systemImage: "icloud.and.arrow.up")
                        }
                    }
                    .disabled(diagnostic.isRunning || !diagnostic.hasSelectedImage)
                } header: {
                    Text("2. Kjør CKAsset-test")
                } footer: {
                    Text("Testen gjenbruker recorden swiftui-poc-textile-image-v1. Nye testkjøringer oppretter derfor ikke stadig nye TextileImage-records.")
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

                if let data = diagnostic.fetchedImageData {
                    Section("Bilde lest tilbake fra CloudKit") {
                        DiagnosticImage(data: data)

                        LabeledContent("Record name", value: diagnostic.imageRecordName)
                        LabeledContent("Nedlastet", value: byteCount(diagnostic.fetchedByteCount))
                    }
                }

                if diagnostic.completedSuccessfully {
                    Section {
                        Label("Steg 7 er fullført", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } footer: {
                        Text("Neste steg er å lese samme Textile og TextileImage på en annen Apple-enhet med samme iCloud-konto.")
                    }
                }
            }
            .navigationTitle("Tekstilig")
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    await loadSelectedPhoto(newItem)
                }
            }
        }
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw PhotoSelectionError.noData
            }

            let contentType = item.supportedContentTypes.first(where: {
                $0.preferredFilenameExtension != nil
            }) ?? .image

            diagnostic.setSelectedImage(
                data: data,
                contentType: contentType.preferredMIMEType ?? contentType.identifier,
                fileExtension: contentType.preferredFilenameExtension ?? "img"
            )
        } catch {
            diagnostic.setSelectionError(error)
        }
    }

    private func byteCount(_ value: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .file)
    }
}

private struct DiagnosticImage: View {
    let data: Data

    var body: some View {
        Group {
            #if canImport(UIKit)
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Testbilde")
            } else {
                fallback
            }
            #elseif canImport(AppKit)
            if let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Testbilde")
            } else {
                fallback
            }
            #else
            fallback
            #endif
        }
    }

    private var fallback: some View {
        Label("Bildet kunne ikke rendres", systemImage: "exclamationmark.triangle")
            .foregroundStyle(.secondary)
    }
}

private enum PhotoSelectionError: LocalizedError {
    case noData

    var errorDescription: String? {
        "Det valgte bildet kunne ikke leses som bildefil. Velg et annet bilde og prøv igjen."
    }
}

#Preview {
    ContentView()
}
