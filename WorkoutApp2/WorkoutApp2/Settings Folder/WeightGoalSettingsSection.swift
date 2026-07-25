//
//  WeightGoalSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct WeightGoalSettingsSection: View {
    @AppStorage("weightGoalDirection") private var weightGoalDirection: String = "lose"
    @AppStorage("showWeightUpdateToast") private var weightUpdateToastEnabled: Bool = true

    var body: some View {
        CollapsibleSettingsSection(
            title: "Weight Goal",
            icon: "target",
            iconColor: .orange
        ) {
            SettingsRow(icon: "scalemass", title: "Goal Direction") {
                Picker("", selection: $weightGoalDirection) {
                    Text("Lose Weight").tag("lose")
                    Text("Gain Weight").tag("gain")
                }
                .pickerStyle(.menu)
            }
            Divider()
            SettingsRow(icon: "bubble.left.and.bubble.right.fill", title: "Weight Update Toast") {
                Toggle("", isOn: $weightUpdateToastEnabled).labelsHidden()
            }
        }
    }
}
