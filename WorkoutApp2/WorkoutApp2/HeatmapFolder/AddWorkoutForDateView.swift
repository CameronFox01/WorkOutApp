//
//  AddWorkoutForDateView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/7/26.
//
import SwiftUI

struct AddWorkoutForDateView: View {
    let date: Date
    @EnvironmentObject var workoutData: WorkoutData
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: WorkoutCategory = .push
    @State private var selectedWorkout: String = ""
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var sets: String = ""
    @State private var distance: String = ""
    @State private var time: String = ""
    @State private var note: String = ""

    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue

    private var unitSystem: UnitSystem { UnitSystem(rawValue: unitSystemRaw) ?? .metric }
    private var weightUnit: String { unitSystem == .imperial ? "lbs" : "kg" }
    private var distanceUnit: String { unitSystem == .imperial ? "mi" : "km" }

    private var isDistanceCardio: Bool { selectedCategory == .distanceCardio }
    private var isTimeCardio: Bool { selectedCategory == .timeCardio }
    private var usesWeight: Bool { selectedCategory.usesWeight && !isDistanceCardio && !isTimeCardio }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.9), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // Date display
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.white.opacity(0.7))
                            Text(date.formatted(date: .complete, time: .omitted))
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(14)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))

                        // Category picker
                        pickerField(label: "Category") {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(WorkoutCategory.allCases) { cat in
                                    Text(cat.title).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedCategory) { _, _ in
                                selectedWorkout = selectedCategory.workouts().first ?? ""
                                // Reset fields when category changes
                                weight = ""; reps = ""; sets = ""
                                distance = ""; time = ""
                            }
                        }

                        // Workout picker
                        pickerField(label: "Workout") {
                            Picker("Workout", selection: $selectedWorkout) {
                                ForEach(selectedCategory.workouts(), id: \.self) { w in
                                    Text(w).tag(w)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        // MARK: - Context-aware stat fields
                        VStack(spacing: 12) {

                            // Weight field — only for weight-based workouts
                            if usesWeight {
                                statRow(
                                    icon: "scalemass",
                                    label: "Weight (\(weightUnit))",
                                    text: $weight,
                                    step: unitSystem == .imperial ? 5 : 2.5
                                )
                            }

                            // Distance — only for distance cardio
                            if isDistanceCardio {
                                statRow(
                                    icon: "ruler",
                                    label: "Distance (\(distanceUnit))",
                                    text: $distance,
                                    step: unitSystem == .imperial ? 0.5 : 1
                                )
                            }

                            // Time — distance cardio and time cardio
                            if isDistanceCardio || isTimeCardio {
                                statRow(
                                    icon: "timer",
                                    label: "Time (min)",
                                    text: $time,
                                    step: 1
                                )
                            }

                            // Reps — everything except time-only cardio
                            if !isTimeCardio {
                                statRow(
                                    icon: "number",
                                    label: "Reps",
                                    text: $reps,
                                    step: 1
                                )
                            }

                            // Sets — everything
                            statRow(
                                icon: "square.grid.2x2",
                                label: "Sets",
                                text: $sets,
                                step: 1
                            )
                        }
                        .padding(16)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))

                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.6))
                            TextField("Optional", text: $note)
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                        }

                        // Save button
                        Button { saveEntry() } label: {
                            Text("Save Workout")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Workout")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            selectedWorkout = selectedCategory.workouts().first ?? ""
        }
    }

    // MARK: - Reusable row with stepper
    private func statRow(
        icon: String,
        label: String,
        text: Binding<String>,
        step: Double
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))

            Spacer()

            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)

            Stepper("", onIncrement: {
                let val = (Double(text.wrappedValue) ?? 0) + step
                text.wrappedValue = formatted(val)
            }, onDecrement: {
                let val = max(0, (Double(text.wrappedValue) ?? 0) - step)
                text.wrappedValue = formatted(val)
            })
            .labelsHidden()
        }
        .padding(12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func pickerField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.6))
            content()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                .colorScheme(.dark)
                .tint(.white)
        }
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    private func saveEntry() {
        guard !selectedWorkout.isEmpty else { return }

        // Map fields based on category type, matching how ImportView saves
        let weightValue: String
        let repsValue: String

        if isDistanceCardio {
            weightValue = distance  // distance cardio stores distance in weight field
            repsValue = time        // and time in reps
        } else if isTimeCardio {
            weightValue = ""
            repsValue = time
        } else {
            weightValue = weight
            repsValue = reps
        }

        let entry = WorkoutEntry(
            workoutType: selectedWorkout,
            weight: weightValue,
            reps: repsValue,
            sets: sets,
            date: date,
            note: note
        )
        workoutData.add(entry: entry)
        dismiss()
    }
}
