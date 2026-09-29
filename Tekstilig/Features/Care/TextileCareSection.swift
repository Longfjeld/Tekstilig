import SwiftUI

struct TextileCareSection: View {
    let textile: Textile
    let onEditCare: () -> Void

    var body: some View {
        Section {
            if textile.care.isEmpty {
                Text("Ingen vedlikeholdsinformasjon registrert")
                    .foregroundStyle(.secondary)
            } else {
                if let value = TextileCareLabels.wash(textile.care) {
                    CareSummaryRow(systemImage: "washer", title: "Vask", value: value)
                }
                if let value = TextileCareLabels.bleach(textile.care.bleach) {
                    CareSummaryRow(systemImage: "triangle", title: "Bleking", value: value)
                }
                if let value = TextileCareLabels.tumbleDry(textile.care.tumbleDry) {
                    CareSummaryRow(systemImage: "dryer", title: "Tørketrommel", value: value)
                }
                if let value = TextileCareLabels.drying(textile.care.drying) {
                    CareSummaryRow(systemImage: "wind", title: "Annen tørking", value: value)
                }
                if let value = TextileCareLabels.iron(textile.care.iron) {
                    CareSummaryRow(systemImage: "thermometer.medium", title: "Stryking", value: value)
                }
                if let value = TextileCareLabels.dryClean(textile.care.dryClean) {
                    CareSummaryRow(systemImage: "sparkles", title: "Rens", value: value)
                }
                if !textile.care.notes.isEmpty {
                    LabeledContent("Merknad", value: textile.care.notes)
                }
            }

            Button(action: onEditCare) {
                Label(
                    textile.care.isEmpty ? "Legg til vedlikehold" : "Rediger vedlikehold",
                    systemImage: "tag"
                )
            }
        } header: {
            Text("Vedlikehold")
        } footer: {
            Text("Første native versjon viser enkle symbolmarkører sammen med forklarende tekst. Standardiserte vaskesymbolgrafikker kan finpusses senere uten å endre de strukturerte dataene.")
        }
    }
}

private struct CareSummaryRow: View {
    let systemImage: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .frame(width: 24)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
            }
        }
        .padding(.vertical, 2)
    }
}
