//
//  SecuritySettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct SecuritySettingsSection: View {
    @AppStorage("faceIDEnabled") private var faceIDEnabled: Bool = false
    @AppStorage("lockGracePeriodSeconds") private var lockGracePeriodSeconds: Int = 0

    var body: some View {
        CollapsibleSettingsSection(
            title: "Security",
            icon: "faceid",
            iconColor: .blue
        ) {
            SettingsRow(icon: "faceid", title: "Require Face ID") {
                Toggle("", isOn: $faceIDEnabled).labelsHidden()
            }
            if faceIDEnabled {
                Divider()
                SettingsRow(icon: "clock", title: "Lock After") {
                    Picker("", selection: $lockGracePeriodSeconds) {
                        ForEach(LockGracePeriod.allCases) { option in
                            Text(option.label).tag(option.rawValue)
                        }
                    }
                    .labelsHidden()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
}
