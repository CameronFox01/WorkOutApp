//
//  GradientSettings.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/16/26.
//


import SwiftUI
import WidgetKit

@MainActor
class GradientSettings: ObservableObject {
    @Published var selectedPreset: GradientPreset

    private let storageKey = "selectedGradientPreset"
    private let defaults = UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")

    init() {
        if let data = defaults?.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(GradientPreset.self, from: data) {
            selectedPreset = decoded
        } else {
            selectedPreset = GradientPreset.presets[0]
        }
    }

    func select(_ preset: GradientPreset) {
        selectedPreset = preset
        save()
    }

    func setCustomColors(_ colors: [Color], name: String = "Custom") {
        selectedPreset = GradientPreset(name: name, colors: colors)
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(selectedPreset) {
            defaults?.set(encoded, forKey: storageKey)
        }
        WidgetCenter.shared.reloadAllTimelines() // tell widgets to refresh now
    }
}

extension GradientSettings {
    var darkGradientColors: [Color] {
        selectedPreset.darkVariant()
    }
}
