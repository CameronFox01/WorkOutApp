//
//  DataSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct DataSettingsSection: View {
    var body: some View {
        CollapsibleSettingsSection(
            title: "Data",
            icon: "externaldrive.fill",
            iconColor: .gray
        ) {
            DataExportSection()
        }
    }
}
