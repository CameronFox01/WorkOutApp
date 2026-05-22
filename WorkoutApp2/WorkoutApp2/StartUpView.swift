//
//  StartUpView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/18/26.
//

import SwiftUI

struct StartUpView: View {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userGender") private var genderRaw: String = Gender.male.rawValue

    @State private var selectedFeet = 5
    @State private var selectedInches = 8
    @State private var selectedCentimeters = 173
    
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Area for Name to be entered
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }
                
                // Area for Gender to be selected
                Section(header: Text("Gender")) {
                    Picker("Gender", selection: $genderRaw) {
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Area for Unit to be selected
                Section(header: Text("Unit System")){
                    Picker("Unit System", selection: Binding<UnitSystem>(
                        get: { UnitSystem(rawValue: unitSystemRaw) ?? .metric },
                        set: { newValue in
                            let oldUnit = UnitSystem(rawValue: unitSystemRaw) ?? .metric
                            if oldUnit != newValue {
                                convertValues(from: oldUnit, to: newValue)
                                unitSystemRaw = newValue.rawValue
                            }
                        }
                    )) {
                        ForEach(UnitSystem.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Area for Body Info
                Section(header: Text("Body Info")) {
                    // HEIGHT
                    if unitSystem == .imperial {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                            HStack {
                                Picker("Feet", selection: $selectedFeet) {
                                    ForEach(3...7, id: \.self) { foot in
                                        Text("\(foot) ft").tag(foot)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)

                                Picker("Inches", selection: $selectedInches) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch) in").tag(inch)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                            Picker("Centimeters", selection: $selectedCentimeters) {
                                ForEach(100...250, id: \.self) { cm in
                                    Text("\(cm) cm").tag(cm)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                    }

                    // WEIGHT
                    TextField(weightLabel, text: $weight)
                        .keyboardType(.decimalPad)
                }

                Button("Finish Setup") {
                    guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

                    // Always persist height from picker state right now
                    if unitSystem == .imperial {
                        let totalInches = (selectedFeet * 12) + selectedInches
                        height = "\(totalInches)"
                    } else {
                        height = "\(selectedCentimeters)"
                    }

//                    DispatchQueue.main.async {
//                         hasCompletedSetup = true
//                     }
                    hasCompletedSetup = true
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Setup Account")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Make sure unit state is consistent and pickers reflect stored value (if any)
                initializePickersFromStoredHeight()

                // If height hasn’t been set yet, populate it from the default picker selections now
                if height.isEmpty {
                    if unitSystem == .imperial {
                        let totalInches = (selectedFeet * 12) + selectedInches
                        height = "\(totalInches)"
                    } else {
                        height = "\(selectedCentimeters)"
                    }
                }
            }
        }
    }

    private func initializePickersFromStoredHeight() {
        // If there is an existing stored height, update the pickers to match it
        guard !height.isEmpty, let stored = Double(height) else { return }
        if unitSystem == .imperial {
            // Height is stored as total inches in your current design
            let totalInches = Int(stored.rounded())
            selectedFeet = max(3, min(7, totalInches / 12))
            selectedInches = max(0, min(11, totalInches % 12))
        } else {
            // Metric: height is stored as cm
            let cm = Int(stored.rounded())
            selectedCentimeters = max(100, min(250, cm))
        }
    }
    
    func convertValues(from oldUnit: UnitSystem, to newUnit: UnitSystem) {
        guard oldUnit != newUnit else { return }

        // Convert height and weight
        if let heightValue = Double(height), let weightValue = Double(weight) {
            switch (oldUnit, newUnit) {
            case (.metric, .imperial):
                height = String(format: "%.1f", heightValue / 2.54)
                weight = String(format: "%.1f", weightValue * 2.20462)
            case (.imperial, .metric):
                height = String(format: "%.1f", heightValue * 2.54)
                weight = String(format: "%.1f", weightValue / 2.20462)
            default:
                break
            }
        }

        // Convert saved workout goals
        let allWorkouts = BodyweightWorkout.allCases.map(\.rawValue)
            + PushWorkout.allCases.map(\.rawValue)
            + PullWorkout.allCases.map(\.rawValue)
            + LegWorkout.allCases.map(\.rawValue)
            + GluteWorkout.allCases.map(\.rawValue)
            + BicepWorkout.allCases.map(\.rawValue)
            + TricepWorkout.allCases.map(\.rawValue)
            + AbsWorkout.allCases.map(\.rawValue)
            + DistanceCardioWorkout.allCases.map(\.rawValue)

        for workout in allWorkouts {
            let key = "goal_\(workout)"
            guard let saved = UserDefaults.standard.string(forKey: key),
                  let value = Double(saved) else { continue }

            let converted: Double
            switch (oldUnit, newUnit) {
            case (.metric, .imperial): converted = value * 2.20462
            case (.imperial, .metric): converted = value / 2.20462
            default: continue
            }

            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: key)
        }

        // Convert target body weight
        if let saved = UserDefaults.standard.string(forKey: "userTargetWeight"),
           let value = Double(saved) {
            let converted: Double
            switch (oldUnit, newUnit) {
            case (.metric, .imperial): converted = value * 2.20462
            case (.imperial, .metric): converted = value / 2.20462
            default: return
            }
            UserDefaults.standard.set(String(format: "%.1f", converted), forKey: "userTargetWeight")
        }
    }

    // MARK: - Labels
    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }

    var heightLabel: String {
        unitSystem == .metric ? "Height (cm)" : "Height (inches)"
    }

    var weightLabel: String {
        unitSystem == .metric ? "Weight (kg)" : "Weight (lbs)"
    }

    var heightUnit: String {
        unitSystem == .metric ? "cm" : "in"
    }

    var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
}

#Preview {
    StartUpView()
}

