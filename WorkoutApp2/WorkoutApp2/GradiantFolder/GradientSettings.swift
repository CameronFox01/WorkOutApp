//
//  GradientSettings.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/16/26.
//


import SwiftUI

@MainActor
class GradientSettings: ObservableObject {
    @Published var selectedPreset: GradientPreset

    private let storageKey = "selectedGradientPreset"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
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
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

extension GradientSettings {
    var darkGradientColors: [Color] {
        selectedPreset.darkVariant()
    }
}
