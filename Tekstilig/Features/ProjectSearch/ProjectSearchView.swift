import Foundation
import SwiftUI

struct ProjectSearchView: View {
    let isActive: Bool

    @State private var textileModel = TextileLibraryModel()
    @State private var attributeIndex = TextileLibraryAttributeIndex()
    @State private var pieceIndex = PieceLibraryIndex()

    @State private var requiredLengthText = ""
    @State private var minimumWidthText = ""
    @State private var category = ""
    @State private var material = ""
    @State private var minimumWeightText = ""
    @State private var maximumWeightText = ""
    @State private var stretchLevel = ""
    @State private var hasSearched = false
    @State private var searchResults: [ProjectSearchMatch] = []
    @State private var reservationMatch: ProjectSearchMatch?
    @FocusState private var focusedNumberField: NumberField?

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    private var requiredLengthCm: Int64? {
        Int64(requiredLengthText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var minimumWidthCm: Int64? {
        Int64(minimumWidthText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var minimumWeight: Int? {
        Int(minimumWeightText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var maximumWeight: Int? {
        Int(maximumWeightText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var numericCriteriaAreValid: Bool {
        let pairs: [(String, Any?)] = [
            (requiredLengthText, requiredLengthCm),
            (minimumWidthText, minimumWidthCm),
            (minimumWeightText, minimumWeight),
            (maximumWeightText, maximumWeight)
        ]

        return pairs.allSatisfy { text, value in
            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value != nil
        }
    }

    private var isLoading: Bool {
        textileModel.isLoading || attributeIndex.isLoading || pieceIndex.isLoading
    }

    private var loadErrorMessage: String? {
        textileModel.errorMessage ?? attributeIndex.errorMessage ?? pieceIndex.errorMessage
    }

    private var hasCriteria: Bool {
        !requiredLengthText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !minimumWidthText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !category.isEmpty ||
        !material.isEmpty ||
        !minimumWeightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !maximumWeightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !stretchLevel.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && !textileModel.hasLoaded {
                    ProgressView("Henter tekstiler og stoffstykker …")
                } else if let loadErrorMessage, textileModel.textiles.isEmpty {
                    ContentUnavailableView {
                        Label("Kunne ikke hente prosjektdata", systemImage: "icloud.slash")
                    } description: {
                        Text(loadErrorMessage)
                    } actions: {
                        Button("Prøv igjen") {
                            Task { await reloadAll() }
                        }
                    }
                } else {
                    List {
                        criteriaSection
                        resultSection
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .refreshable {
                        await reloadAll()
                        if hasSearched {
                            performSearch()
                        }
                    }
                }
            }
            .navigationTitle("Finn til prosjekt")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Ferdig") {
                        focusedNumberField = nil
                    }
                }
            }
            .task(id: isActive) {
                guard isActive else { return }

                if textileModel.hasLoaded && attributeIndex.hasLoaded && pieceIndex.hasLoaded {
                    await reloadAll()
                    if hasSearched {
                        performSearch()
                    }
                } else {
                    await loadAllIfNeeded()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .tekstiligPieceDidChange)) { notification in
                guard let piece = notification.object as? Piece else { return }

                if notification.userInfo?["deleted"] as? Bool == true {
                    pieceIndex.remove(piece)
                } else {
                    pieceIndex.upsert(piece)
                }

                if hasSearched {
                    performSearch()
                }
            }
            .sheet(item: $reservationMatch) { match in
                ProjectReservationView(
                    piece: match.piece,
                    suggestedLengthCm: requiredLengthCm
                ) { savedPiece in
                    pieceIndex.upsert(savedPiece)
                    performSearch()
                }
            }
        }
    }

    private var criteriaSection: some View {
        Section {
            TextField("Lengde minst (cm)", text: $requiredLengthText)
                .keyboardType(.numberPad)
                .focused($focusedNumberField, equals: .length)

            TextField("Bredde minst (cm)", text: $minimumWidthText)
                .keyboardType(.numberPad)
                .focused($focusedNumberField, equals: .width)

            Picker("Kategori", selection: $category) {
                Text("Alle kategorier").tag("")
                ForEach(Textile.categoryOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }

            Picker("Materiale", selection: $material) {
                Text("Alle materialer").tag("")
                ForEach(TextileMaterial.materialOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .disabled(attributeIndex.isLoading || attributeIndex.errorMessage != nil)

            HStack {
                TextField("Min g/m²", text: $minimumWeightText)
                    .keyboardType(.numberPad)
                    .focused($focusedNumberField, equals: .minimumWeight)
                Text("–")
                    .foregroundStyle(.secondary)
                TextField("Maks g/m²", text: $maximumWeightText)
                    .keyboardType(.numberPad)
                    .focused($focusedNumberField, equals: .maximumWeight)
            }

            Picker("Elastisitet", selection: $stretchLevel) {
                Text("Alle nivåer").tag("")
                Text("Ingen").tag("none")
                Text("Lav").tag("low")
                Text("Middels").tag("medium")
                Text("Høy").tag("high")
            }

            Button("Finn tekstiler") {
                focusedNumberField = nil
                performSearch()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasCriteria || !numericCriteriaAreValid || isLoading)

            if hasCriteria || hasSearched {
                Button("Nullstill kriterier") {
                    resetCriteria()
                }
            }
        } header: {
            Text("Krav")
        } footer: {
            Text("Lengde vurderes som gjenværende sammenhengende tilgjengelig lengde etter eventuell reservasjon.")
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if !hasSearched {
            Section("Resultater") {
                Text("Angi ett eller flere krav og trykk Finn tekstiler.")
                    .foregroundStyle(.secondary)
            }
        } else if !hasCriteria {
            Section("Resultater") {
                Text("Angi minst ett kriterium før du søker.")
                    .foregroundStyle(.secondary)
            }
        } else if searchResults.isEmpty {
            Section("Resultater") {
                ContentUnavailableView(
                    "Ingen treff",
                    systemImage: "magnifyingglass",
                    description: Text("Ingen stoffstykker oppfyller alle de valgte kravene.")
                )
            }
        } else {
            Section("Resultater") {
                ForEach(searchResults) { match in
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink {
                            TextileDetailView(
                                textileIdentity: match.textile.id,
                                model: textileModel
                            )
                        } label: {
                            ProjectSearchResultRow(match: match)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }

                        Button {
                            reservationMatch = match
                        } label: {
                            Label(
                                match.piece.isReserved ? "Endre reservasjon" : "Reserver stykke",
                                systemImage: "bookmark"
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func loadAllIfNeeded() async {
        await textileModel.loadIfNeeded()
        await attributeIndex.loadIfNeeded()
        await pieceIndex.loadIfNeeded()
    }

    private func reloadAll() async {
        await textileModel.load()
        await attributeIndex.load()
        await pieceIndex.load()
    }

    private func resetCriteria() {
        focusedNumberField = nil
        requiredLengthText = ""
        minimumWidthText = ""
        category = ""
        material = ""
        minimumWeightText = ""
        maximumWeightText = ""
        stretchLevel = ""
        hasSearched = false
        searchResults = []
    }

    private func performSearch() {
        hasSearched = true

        guard hasCriteria else {
            searchResults = []
            return
        }

        var result: [ProjectSearchMatch] = []

        for textile in textileModel.textiles {
            if !category.isEmpty,
               textile.category.localizedCaseInsensitiveCompare(category) != .orderedSame {
                continue
            }

            if !material.isEmpty {
                let materials = attributeIndex.materials(for: textile.textileID)
                guard materials.contains(where: {
                    $0.material.localizedCaseInsensitiveCompare(material) == .orderedSame
                }) else {
                    continue
                }
            }

            if let minimumWeight {
                guard let weight = textile.weightGsm, weight >= minimumWeight else {
                    continue
                }
            }

            if let maximumWeight {
                guard let weight = textile.weightGsm, weight <= maximumWeight else {
                    continue
                }
            }

            if !stretchLevel.isEmpty,
               textile.stretch.level != stretchLevel {
                continue
            }

            var bestPiece: Piece?
            var bestAvailableLength: Int64 = -1
            var bestWidth: Int64 = -1
            var bestPieceID = ""

            for piece in pieceIndex.pieces(for: textile.textileID) {
                let availableLength = piece.availableLengthCm

                if let requiredLengthCm, availableLength < requiredLengthCm {
                    continue
                }
                if let minimumWidthCm, piece.widthCm < minimumWidthCm {
                    continue
                }
                guard availableLength > 0 else {
                    continue
                }

                let isBetter: Bool
                if availableLength != bestAvailableLength {
                    isBetter = availableLength > bestAvailableLength
                } else if piece.widthCm != bestWidth {
                    isBetter = piece.widthCm > bestWidth
                } else {
                    isBetter = bestPiece == nil ||
                        piece.pieceID.localizedCaseInsensitiveCompare(bestPieceID) == .orderedAscending
                }

                if isBetter {
                    bestPiece = piece
                    bestAvailableLength = availableLength
                    bestWidth = piece.widthCm
                    bestPieceID = piece.pieceID
                }
            }

            guard let bestPiece else {
                continue
            }

            result.append(
                ProjectSearchMatch(
                    textile: textile,
                    piece: bestPiece,
                    materials: attributeIndex.materials(for: textile.textileID),
                    availableLengthCm: bestAvailableLength,
                    widthCm: bestWidth
                )
            )
        }

        searchResults = result.sorted { lhs, rhs in
            if lhs.availableLengthCm != rhs.availableLengthCm {
                return lhs.availableLengthCm > rhs.availableLengthCm
            }
            if lhs.widthCm != rhs.widthCm {
                return lhs.widthCm > rhs.widthCm
            }
            return lhs.textile.name.localizedCaseInsensitiveCompare(rhs.textile.name) == .orderedAscending
        }
    }
}

private enum NumberField: Hashable {
    case length
    case width
    case minimumWeight
    case maximumWeight
}

private struct ProjectSearchMatch: Identifiable {
    let textile: Textile
    let piece: Piece
    let materials: [TextileMaterial]
    let availableLengthCm: Int64
    let widthCm: Int64

    var id: String { textile.id }
}

private struct ProjectSearchResultRow: View {
    let match: ProjectSearchMatch

    private var materialSummary: String {
        let values = match.materials.map { material in
            if let percentage = material.percent {
                return "\(percentage) % \(material.material)"
            }
            return material.material
        }
        return values.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(match.textile.name)
                .font(.headline)

            Text("Stykke på \(match.availableLengthCm) cm × \(match.widthCm) cm tilgjengelig")
                .font(.subheadline)

            if !materialSummary.isEmpty {
                Text(materialSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let weight = match.textile.weightGsm {
                Text("\(weight) g/m²")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if match.piece.isReserved {
                Text("\(match.piece.reservedLengthCm) cm er reservert til \(match.piece.project)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProjectSearchView()
}
