import ImageIO
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct TextileEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Textile) async throws -> Textile

    @State private var draft: Textile
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pendingImage: QuickRegistrationImage?
    @State private var imageModel = TextileImageModel()
    @State private var showLocation = false
    @State private var isQuickRegistration: Bool

    #if os(iOS)
    @State private var showCamera = false
    #endif

    init(
        textile: Textile?,
        onSave: @escaping (Textile) async throws -> Textile
    ) {
        self.onSave = onSave
        _draft = State(initialValue: textile ?? Textile.newDraft())
        _isQuickRegistration = State(initialValue: textile == nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                if isQuickRegistration {
                    quickImageSection

                    Section("Grunnopplysninger") {
                        TextField("Navn", text: $draft.name)
                            .textInputAutocapitalization(.sentences)
                    }

                    Section {
                        DisclosureGroup("Plassering (valgfritt)", isExpanded: $showLocation) {
                            TextField("Område / rom", text: $draft.locationArea)
                                .textInputAutocapitalization(.sentences)
                            TextField("Hylle", text: $draft.locationShelf)
                                .textInputAutocapitalization(.sentences)
                            TextField("Beholder / kasse", text: $draft.locationContainer)
                                .textInputAutocapitalization(.sentences)
                        }
                    } footer: {
                        Text("Du kan komplettere materiale, farge, stoffstykker og andre opplysninger senere.")
                    }
                } else {
                    Section("Grunnopplysninger") {
                        TextField("Navn", text: $draft.name)

                        Picker("Kategori", selection: $draft.category) {
                            Text("Ikke valgt").tag("")
                            ForEach(Textile.categoryOptions, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    }

                    Section("Notat") {
                        TextEditor(text: $draft.notes)
                            .frame(minHeight: 120)
                    }

                    Section {
                        Text("Bilde, plassering, materiale, farge og stoffstykker redigeres i egne seksjoner på tekstildetaljen.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isQuickRegistration ? "Nytt tekstil" : "Rediger tekstil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Lagrer …" : "Lagre") {
                        save()
                    }
                    .disabled(
                        isSaving ||
                        draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .interactiveDismissDisabled(isSaving)
            .onChange(of: selectedPhotoItem) { _, item in
                guard let item else { return }
                loadSelectedPhoto(item)
            }
            .alert(
                "Kunne ikke lagre",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Ukjent feil")
            }
            #if os(iOS)
            .sheet(isPresented: $showCamera) {
                TextileCameraPicker { data in
                    prepareImage(data)
                }
                .ignoresSafeArea()
            }
            #endif
        }
    }

    @ViewBuilder
    private var quickImageSection: some View {
        Section {
            if let pendingImage {
                QuickRegistrationImagePreview(data: pendingImage.data)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 12) {
                    #if os(iOS)
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Ta nytt bilde") {
                            showCamera = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    #endif

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Velg annet")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            } else {
                #if os(iOS)
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showCamera = true
                    } label: {
                        Text("Ta bilde")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                #endif

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Velg fra Bilder", systemImage: "photo.on.rectangle")
                }
            }
        } header: {
            Text("Bilde")
        } footer: {
            Text("Bilde er valgfritt. Tekstilig optimaliserer bildet til JPEG før det lagres i CloudKit.")
        }
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self), !data.isEmpty else {
                    throw QuickRegistrationImageError.emptyData
                }
                prepareImage(data)
            } catch {
                errorMessage = error.localizedDescription
            }
            selectedPhotoItem = nil
        }
    }

    private func prepareImage(_ sourceData: Data) {
        do {
            let optimized = try QuickRegistrationImageOptimizer.optimize(sourceData)
            pendingImage = QuickRegistrationImage(
                data: optimized,
                fileName: "tekstilig-main-\(UUID().uuidString.lowercased()).jpg",
                contentType: "image/jpeg"
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() {
        guard !isSaving else { return }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                let saved = try await onSave(draft)
                draft = saved

                if let pendingImage {
                    let imageSaved = await imageModel.savePrimaryImage(
                        textileID: saved.textileID,
                        data: pendingImage.data,
                        fileName: pendingImage.fileName,
                        contentType: pendingImage.contentType
                    )

                    guard imageSaved else {
                        errorMessage = imageModel.errorMessage ?? "Tekstilet ble lagret, men bildet kunne ikke lagres. Prøv å lagre på nytt."
                        isSaving = false
                        return
                    }
                }

                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

private struct QuickRegistrationImage {
    let data: Data
    let fileName: String
    let contentType: String
}

private enum QuickRegistrationImageOptimizer {
    static let maximumPixelSize = 2_048
    static let jpegQuality = 0.82

    static func optimize(_ sourceData: Data) throws -> Data {
        guard let source = CGImageSourceCreateWithData(sourceData as CFData, nil) else {
            throw QuickRegistrationImageError.invalidImage
        }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize
        ]

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            throw QuickRegistrationImageError.invalidImage
        }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw QuickRegistrationImageError.encodingFailed
        }

        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary
        )

        guard CGImageDestinationFinalize(destination), output.length > 0 else {
            throw QuickRegistrationImageError.encodingFailed
        }

        return output as Data
    }
}

private enum QuickRegistrationImageError: LocalizedError {
    case emptyData
    case invalidImage
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .emptyData:
            return "Bildet kunne ikke leses."
        case .invalidImage:
            return "Det valgte bildet kunne ikke behandles som et gyldig bilde."
        case .encodingFailed:
            return "Bildet kunne ikke optimaliseres før lagring."
        }
    }
}

private struct QuickRegistrationImagePreview: View {
    let data: Data

    var body: some View {
        Group {
            #if os(iOS)
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                fallback
            }
            #elseif os(macOS)
            if let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                fallback
            }
            #else
            fallback
            #endif
        }
        .frame(maxHeight: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var fallback: some View {
        ContentUnavailableView("Kunne ikke vise bildet", systemImage: "photo")
    }
}

#if os(iOS)
private struct TextileCameraPicker: UIViewControllerRepresentable {
    let onImageData: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: TextileCameraPicker

        init(parent: TextileCameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 1.0) {
                parent.onImageData(data)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif
