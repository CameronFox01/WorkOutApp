//
//  UnitsSettingsSection.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/24/26.
//
import SwiftUI
import Foundation
import WidgetKit

struct UnitsSettingsSection: View {
    @EnvironmentObject var workoutData: WorkoutData
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    @State private var showUnitChangeConfirmation = false
    @State private var pendingUnitSystem: String = ""

    var body: some View {
        CollapsibleSettingsSection(
            title: "Units",
            icon: "ruler.fill",
            iconColor: .teal
        ) {
            SettingsRow(icon: "scalemass", title: "Unit System") {
                Picker("", selection: Binding(
                    get: { unitSystemRaw },
                    set: { newValue in
                        pendingUnitSystem = newValue
                        showUnitChangeConfirmation = true
                    }
                )) {
                    Text("Imperial (lbs, in, mi)").tag(UnitSystem.imperial.rawValue)
                    Text("Metric (kg, cm, km)").tag(UnitSystem.metric.rawValue)
                }
                .pickerStyle(.menu)
            }

            Text("All saved values will be automatically converted.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .confirmationDialog(
            "Switch Unit System?",
            isPresented: $showUnitChangeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Convert All Data") {
                let newSystem = UnitSystem(rawValue: pendingUnitSystem) ?? .metric
                convertAllDataToNewUnit(newSystem: newSystem)
                unitSystemRaw = pendingUnitSystem
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will convert all your saved weights, measurements, and workout data to the new unit system.")
        }
    }

    private func convertAllDataToNewUnit(newSystem: UnitSystem) {
        let isNowMetric = newSystem == .metric

        if let w = Double(UserDefaults.standard.string(forKey: "userWeight") ?? "") {
            let converted = isNowMetric ? w / 2.20462 : w * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userWeight")
        }
        if let tw = Double(UserDefaults.standard.string(forKey: "userTargetWeight") ?? "") {
            let converted = isNowMetric ? tw / 2.20462 : tw * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userTargetWeight")
        }
        if let ow = Double(UserDefaults.standard.string(forKey: "userOriginalWeight") ?? "") {
            let converted = isNowMetric ? ow / 2.20462 : ow * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userOriginalWeight")
        }
        if let bw = Double(UserDefaults.standard.string(forKey: "userBaselineWeightForGoal") ?? "") {
            let converted = isNowMetric ? bw / 2.20462 : bw * 2.20462
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userBaselineWeightForGoal")
        }
        if let h = Double(UserDefaults.standard.string(forKey: "userHeight") ?? "") {
            let converted = isNowMetric ? h * 2.54 : h / 2.54
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userHeight")
        }

        let measurementKeys = [
            "measureChest", "measureWaist", "measureHips",
            "measureBiceps", "measureThighs", "measureNeck",
            "measureCalves", "measureShoulders"
        ]
        for key in measurementKeys {
            if let val = Double(UserDefaults.standard.string(forKey: key) ?? "") {
                let converted = isNowMetric ? val * 2.54 : val / 2.54
                UserDefaults.standard.set(String(format: "%.1f", converted), forKey: key)
            }
        }

        let historyKey = "measurementHistory"
        if let data = UserDefaults.standard.data(forKey: historyKey),
           var entries = try? JSONDecoder().decode([MeasurementEntry].self, from: data) {
            entries = entries.map { entry in
                var e = entry
                let convert: (Double?) -> Double? = { val in
                    guard let v = val else { return nil }
                    return isNowMetric ? v * 2.54 : v / 2.54
                }
                e.chest     = convert(e.chest)
                e.shoulders = convert(e.shoulders)
                e.waist     = convert(e.waist)
                e.hips      = convert(e.hips)
                e.biceps    = convert(e.biceps)
                e.thighs    = convert(e.thighs)
                e.neck      = convert(e.neck)
                e.calves    = convert(e.calves)
                return e
            }
            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: historyKey)
            }
        }

        if let data = UserDefaults.standard.data(forKey: "workout_entries"),
           var entries = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = entries.map { entry in
                var e = entry
                let isDistanceCardio = DistanceCardioWorkout.allCases.map(\.rawValue).contains(e.workoutType)
                if !isDistanceCardio, let w = Double(e.weight) {
                    let converted = isNowMetric ? w / 2.20462 : w * 2.20462
                    e.weight = String(format: "%.1f", converted)
                }
                if isDistanceCardio, let d = Double(e.weight) {
                    let converted = isNowMetric ? d * 1.60934 : d / 1.60934
                    e.weight = String(format: "%.2f", converted)
                }
                return e
            }
            if let encoded = try? JSONEncoder().encode(entries) {
                UserDefaults.standard.set(encoded, forKey: "workout_entries")
            }
            workoutData.reload()
        }
    }
}
