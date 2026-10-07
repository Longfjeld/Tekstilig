import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct TextileMainImageSection: View {
    let textile: Textile

    @State private var model = TextileImageModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

    #if os(iOS)
    @State private var showCamera = false
    #endif

    var body: some View {
        Section {
            if model.isLoading && model.primaryImage == nil {
                ProgressView("Henter hovedbilde …")
            } else if let primaryImage = model.primaryImage {
                let isSaving = model.isSaving

                VStack(alignment: .leading, spacing: 12) {
                    platformImage(data: primaryImage.data)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: 12) {
                        #if os(iOS)
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button("Ta nytt bilde") {
                                showCamera = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(isSaving)
                        }
                        #endif

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text("Velg annet")
                        }
                        .buttonStyle(.bordered)
                        .disabled(isSaving)
                    }
                }
                .padding(.vertical, 4)
            } else if let errorMessage = model.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Kunne ikke hente hovedbilde", systemImage: "icloud.slash")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Button("Prøv igjen") {
                        Task {
                            await model.load(for: textile.textileID)
                        }
                    }
                }
                .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Ingen bilder registrert", systemImage: "photo")
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        #if os(iOS)
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button("Ta bilde") {
                                showCamera = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(model.isSaving)
                        }
                        #endif

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text("Velg fra Bilder")
                        }
                        .buttonStyle(.bordered)
                        .disabled(model.isSaving)
                    }
                }
                .padding(.vertical, 4)
            }

            if model.isSaving {
                ProgressView("Lagrer i CloudKit …")
            }
        } header: {
            Text("Hovedbilde")
        } footer: {
            Text("Ta bilde med kamera eller velg fra Bilder. Tekstilig optimaliserer bildet til JPEG før det lagres i CloudKit.")
        }
        .task(id: textile.textileID) {
            await model.loadIfNeeded(for: textile.textileID)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            loadAndSave(newItem)
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showCamera) {
            TextileCameraPicker { data in
                optimizeAndSave(data)
            }
            .ignoresSafeArea()
        }
        #endif
        .alert(
            "Kunne ikke lagre bilde",
            isPresented: Binding(
                get: { model.errorMessage != nil && model.primaryImage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "Ukjent feil")
        }
    }

    @ViewBuilder
    private func platformImage(data: Data) -> some View {
        #if os(iOS)
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            imagePlaceholder
        }
        #elseif os(macOS)
        if let image = NSImage(data: data) {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            imagePlaceholder
        }
        #else
        imagePlaceholder
        #endif
    }

    private var imagePlaceholder: some View {
        ContentUnavailableView("Kunne ikke vise bildet", systemImage: "photo")
    }

    private func loadAndSave(_ item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      !data.isEmpty else {
                    throw TextileImageSelectionError.emptyData
                }

                await saveOptimized(data)
                selectedPhotoItem = nil
            } catch {
                model.errorMessage = error.localizedDescription
                selectedPhotoItem = nil
            }
        }
    }

    private func optimizeAndSave(_ data: Data) {
        Task {
            await saveOptimized(data)
        }
    }

    private func saveOptimized(_ data: Data) async {
        do {
            let optimized = try QuickRegistrationImageOptimizer.optimize(data)
            let fileName = "tekstilig-main-\(UUID().uuidString.lowercased()).jpg"

            await model.savePrimaryImage(
                textileID: textile.textileID,
                data: optimized,
                fileName: fileName,
                contentType: "image/jpeg"
            )
        } catch {
            model.errorMessage = error.localizedDescription
        }
    }
}

private enum TextileImageSelectionError: LocalizedError {
    case emptyData

    var errorDescription: String? {
        "Det valgte bildet kunne ikke leses fra Bilder."
    }
}
