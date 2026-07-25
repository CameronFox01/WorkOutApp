//
//  BackgroundSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation

struct BackgroundSettingsSection: View {
    var body: some View {
        CollapsibleSettingsSection(
            title: "Background",
            icon: "paintpalette.fill",
            iconColor: .purple
        ) {
            GradientPickerSection()
        }
    }
}
