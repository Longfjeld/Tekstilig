import SwiftUI

struct TextilePhysicalPropertiesSection: View {
    let textile: Textile
    let onEdit: () -> Void

    private var isEmpty: Bool {
        textile.weightGsm == nil && textile.stretch.isEmpty && textile.shrinkage.isEmpty
    }

    var body: some View {
        Section {
            if isEmpty {
                Text("Ingen vekt, elastisitet eller krymp registrert")
                    .foregroundStyle(.secondary)
            } else {
                if let weightGsm = textile.weightGsm {
                    LabeledContent("Vekt", value: "\(weightGsm) g/m²")
                }

                if !textile.stretch.isEmpty {
                    if let level = TextilePhysicalPropertyLabels.stretchLevel(textile.stretch.level) {
                        LabeledContent("Elastisitet", value: level)
                    }
                    if textile.stretch.level != "none",
                       let direction = TextilePhysicalPropertyLabels.stretchDirection(textile.stretch.direction) {
                        LabeledContent("Retning", value: direction)
                    }
                    if let percent = textile.stretch.percent {
                        LabeledContent("Elastisitet, prosent", value: "\(percent) %")
                    }
                }

                if !textile.shrinkage.isEmpty {
                    if let lengthPercent = textile.shrinkage.lengthPercent {
                        LabeledContent("Krymp, lengde", value: "\(lengthPercent) %")
                    }
                    if let widthPercent = textile.shrinkage.widthPercent {
                        LabeledContent("Krymp, bredde", value: "\(widthPercent) %")
                    }
                    if !textile.shrinkage.note.isEmpty {
                        LabeledContent("Krymp, merknad", value: textile.shrinkage.note)
                    }
                }
            }

            Button(action: onEdit) {
                Label(
                    isEmpty ? "Legg til vekt/elastisitet/krymp" : "Rediger vekt/elastisitet/krymp",
                    systemImage: "ruler"
                )
            }
        } header: {
            Text("Fysiske egenskaper")
        } footer: {
            Text("Vekt registreres i g/m². Elastisitet og krymp kan registreres delvis og kompletteres senere.")
        }
    }
}
