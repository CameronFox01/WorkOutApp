//
//  AccountView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

// TODO: This needs to be have a design that is nice to see. This is ugly/boring.
import SwiftUI

struct AccountView: View {
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userBirthday") private var birthday = Date()
    //@AppStorage("userAge") private var age: String = ""

    var body: some View {
        Form {
            
            TextField("Name", text: $name)

            TextField(heightLabel, text: $height)
                .keyboardType(.decimalPad)

            TextField(weightLabel, text: $weight)
                .keyboardType(.decimalPad)
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)

            Picker("Unit System", selection: Binding<UnitSystem>(
                get: {
                    UnitSystem(rawValue: unitSystemRaw) ?? .metric
                },
                set: { newValue in
                    let oldUnit = UnitSystem(rawValue: unitSystemRaw) ?? .metric
                    if oldUnit != newValue {
                        convertValues(from: oldUnit, to: newValue)
                        unitSystemRaw = newValue.rawValue
                    }
                }
            )) {
                ForEach(UnitSystem.allCases, id: \.self) { unit in
                    Text(unit.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            //I think this will be deleted
            Text("Saved: \(name) \(height) \(heightUnit), \(weight) \(weightUnit) \(age)")
        }
        .navigationTitle("Account")
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

    // MARK: - Conversion
    func convertValues(from oldUnit: UnitSystem, to newUnit: UnitSystem) {
        guard let heightValue = Double(height),
              let weightValue = Double(weight),
              oldUnit != newUnit else { return }

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
    
    //Age Calculation
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }
}

#Preview {
    AccountView()
}
