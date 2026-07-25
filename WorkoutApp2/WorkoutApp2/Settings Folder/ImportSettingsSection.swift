//
//  ImportSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct ImportSettingsSection: View {
    @AppStorage("saveButtonAction") private var GoToHomeScreenWhenSaved: Bool = false
    @AppStorage("SaveToPhotosApp") private var saveToPhoto: Bool = true

    var body: some View {
        CollapsibleSettingsSection(
            title: "Import Settings",
            icon: "square.and.arrow.down",
            iconColor: .green
        ) {
            SettingsRow(icon: "square.and.arrow.down", title: "Return Home After Import") {
                Toggle("", isOn: $GoToHomeScreenWhenSaved).labelsHidden()
            }
            Divider()
            SettingsRow(icon: "photo.on.rectangle", title: "Save to Photos App") {
                Toggle("", isOn: $saveToPhoto).labelsHidden()
            }
        }
    }
}
