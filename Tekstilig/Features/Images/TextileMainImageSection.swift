import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct TextileMainImageSection: View {
    let textile: Textile

    @State private var model = TextileImageModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Section {
            if model.isLoading && model.primaryImage == nil {
                ProgressView("Henter hovedbilde …")
            } else if let primaryImage = model.primaryImage,
                      let uiImage = UIImage(data: primaryImage.data) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(
                            model.isSaving ? "Lagrer bilde …" : "Bytt hovedbilde",
                            systemImage: "photo.badge.plus"
                        )
                    }
                    .disabled(model.isSaving)
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

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Velg hovedbilde", systemImage: "photo.badge.plus")
                    }
                    .disabled(model.isSaving)
                }
                .padding(.vertical, 4)
            }

            if model.isSaving {
                ProgressView("Lagrer i CloudKit …")
            }
        } header: {
            Text("Hovedbilde")
        } footer: {
            Text("Denne versjonen velger bilde fra Bilder. Kamera og bildeoptimalisering kommer i et senere steg.")
        }
        .task(id: textile.textileID) {
            await model.loadIfNeeded(for: textile.textileID)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            loadAndSave(newItem)
        }
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

    private func loadAndSave(_ item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      !data.isEmpty else {
                    throw TextileImageSelectionError.emptyData
                }

                let contentType = item.supportedContentTypes.first ?? .data
                let fileExtension = contentType.preferredFilenameExtension ?? "bin"
                let mimeType = contentType.preferredMIMEType ?? "application/octet-stream"
                let fileName = "tekstilig-main-\(UUID().uuidString.lowercased()).\(fileExtension)"

                await model.savePrimaryImage(
                    textileID: textile.textileID,
                    data: data,
                    fileName: fileName,
                    contentType: mimeType
                )

                selectedPhotoItem = nil
            } catch {
                model.errorMessage = error.localizedDescription
                selectedPhotoItem = nil
            }
        }
    }
}

private enum TextileImageSelectionError: LocalizedError {
    case emptyData

    var errorDescription: String? {
        "Det valgte bildet kunne ikke leses fra Bilder."
    }
}
