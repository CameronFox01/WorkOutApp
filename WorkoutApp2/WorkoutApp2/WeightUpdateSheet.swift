//
//  WeightUpdateSheet.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 5/21/26.
//

import SwiftUI

struct WeightUpdateSheet: View {
    let unitSystem: UnitSystem
    let weightUnit: String
    @Binding var currentWeight: String
    @Binding var newWeightInput: String
    var entries: [WorkoutEntry]
    let onSave: (String) -> Void
    let unitSystemRaw: String

    @Environment(\.dismiss) private var dismiss

    private var bodyWeightEntries: [WorkoutEntry] {
        entries.filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Mini chart using existing WorkoutProgressChart for consistency
                WorkoutProgressChart(
                    workoutName: "Body Weight",
                    entries: entries,
                    unitSystemRaw: unitSystemRaw
                )
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.top, 100) // Brings it from the top to lower
                .padding(.bottom, 60) // Brings the space between the graph and entering in a new weight to be bigger

                VStack(alignment: .leading, spacing: 25) {
                    Text("Enter new weight (") + Text(weightUnit).bold() + Text(")")
                    HStack(spacing: 12) {
                        TextField("e.g. 180", text: $newWeightInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Stepper("", onIncrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            newWeightInput = String(format: "%.1f", current + (unitSystem == .imperial ? 1.0 : 0.5))
                        }, onDecrement: {
                            let current = Double(newWeightInput) ?? Double(currentWeight) ?? 0
                            let next = max(0, current - (unitSystem == .imperial ? 1.0 : 0.5))
                            newWeightInput = String(format: "%.1f", next)
                        })
                        .labelsHidden()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Update Weight")
                        .font(.title2).bold()
                        .foregroundStyle(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = newWeightInput.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty, Double(trimmed) != nil else { return }
                        onSave(trimmed)
                        currentWeight = trimmed
                        dismiss()
                    }
                    .disabled(Double(newWeightInput) == nil)
                }
            }
        }
    }
}


struct WeightUpdateSheet_Previews: PreviewProvider {
    
    struct PreviewWrapper: View {
        @State private var currentWeight = "180"
        @State private var newWeightInput = "180"

        let sampleEntries = [
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "185",
                reps: "",
                sets: "",
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "183",
                reps: "",
                sets: "",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "180",
                reps: "",
                sets: "",
                date: Date()
            )
        ]

        var body: some View {
            WeightUpdateSheet(
                unitSystem: .imperial,
                weightUnit: "lbs",
                currentWeight: $currentWeight,
                newWeightInput: $newWeightInput,
                entries: sampleEntries,
                onSave: { value in
                    print(value)
                },
                unitSystemRaw: UnitSystem.imperial.rawValue
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
