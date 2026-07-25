//
//  CalculatorSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct CalculatorSettingsSection: View {
    @AppStorage("showCalculatorImporting") private var showCalculatorImporting: Bool = true

    var body: some View {
        CollapsibleSettingsSection(
            title: "Calculator",
            icon: "plus.circle",
            iconColor: .red
        ) {
            SettingsRow(icon: "plus", title: "Show Calculator during import") {
                Toggle("", isOn: $showCalculatorImporting).labelsHidden()
            }
        }
    }
}
