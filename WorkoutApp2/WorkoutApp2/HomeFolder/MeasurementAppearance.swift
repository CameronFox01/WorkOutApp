//
//  MeasurementAppearance.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/25/26.
//
import SwiftUI

struct MeasurementAppearance {
    static func color(for label: String) -> Color {
        switch label {
        case "Chest":     return .blue
        case "Shoulders": return .cyan
        case "Neck":      return .purple
        case "Waist":     return .orange
        case "Hips":      return .yellow
        case "Biceps":    return .indigo
        case "Thighs":    return .mint
        case "Calves":    return .green
        default:          return .blue
        }
    }
}
