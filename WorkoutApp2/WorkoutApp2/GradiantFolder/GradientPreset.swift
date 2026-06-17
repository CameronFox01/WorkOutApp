//
//  GradientPreset.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/16/26.
//


import SwiftUI

struct GradientPreset: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var colors: [CodableColor]

    init(id: UUID = UUID(), name: String, colors: [Color]) {
        self.id = id
        self.name = name
        self.colors = colors.map(CodableColor.init)
    }

    var swiftUIColors: [Color] {
        colors.map(\.color)
    }

    static let presets: [GradientPreset] = [
        GradientPreset(name: "Ocean", colors: [.blue.opacity(1.0), .cyan.opacity(0.6), Color(.systemBackground)]),
        GradientPreset(name: "Sunset", colors: [.pink, .orange.opacity(0.6), Color(.systemBackground)]),
        GradientPreset(name: "Forest", colors: [.green, .mint, Color(.systemBackground)]),
        GradientPreset(name: "Midnight", colors: [.indigo, .purple, Color(.systemBackground)]),
        GradientPreset(name: "Steel", colors: [.black, .gray, .white])
        //GradientPreset(name: "Lavendar", colors: [.purple.opacity(0.8), .pink.opacity(0.5), Color(.systemBackground)])
    ]
    
    func darkVariant(intensity: Double = 1.0) -> [Color] {
        guard let baseColor = colors.first else {
            return [.black]
        }
        return [
            baseColor.color.opacity(0.9),
            Color.black.opacity(intensity)
        ]
    }
}

extension GradientPreset {
    /// The color closest to where the toolbar sits (top of the gradient).
    var topColor: Color {
        colors.first?.color.opacity(0.4) ?? .blue
    }
    
    /// The first two colors of the preset, softened for use as a card background.
    var cardColors: [Color] {
        let base = swiftUIColors
        guard base.count >= 2 else {
            return [Color.blue.opacity(0.95), Color.cyan.opacity(0.5)]
        }
        return [base[0].opacity(0.95), base[1].opacity(0.5)]
    }
    
    /// the color for the symbols and text
    var textColor: Color {
        colors.first?.color ?? .blue
    }
}


