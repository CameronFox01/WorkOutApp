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
    let comingFromWidget: Bool
    
    @EnvironmentObject var router: AppRouter

    @Binding var currentWeight: String
    @Binding var newWeightInput: String
    
    @FocusState private var isWeightFieldFocused: Bool

    var entries: [WorkoutEntry]

    let onSave: (String) -> Void
    let unitSystemRaw: String

    @Environment(\.dismiss) private var dismiss

    private var bodyWeightEntries: [WorkoutEntry] {
        entries
            .filter { $0.workoutType == "Body Weight" }
            .sorted { $0.date < $1.date }
    }

    private var progress: CGFloat {

        guard let current = Double(currentWeight),
              let new = Double(newWeightInput.isEmpty ? currentWeight : newWeight),
              current > 0 else {
            return 0
        }

        return CGFloat(min(new / current, 1))
    }

    private var newWeight: String {
        newWeightInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.9),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 28) {
                        TextField(
                            "Enter weight",
                            text: $newWeightInput
                        )
                        .keyboardType(.decimalPad)
                        .font(
                            .system(
                                size: 42,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .focused($isWeightFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {

                                Spacer()

                                Button("Done") {
                                    isWeightFieldFocused = false
                                }
                            }
                        }
                        .onTapGesture {
                            isWeightFieldFocused = false
                        }

                        Divider()
                            .overlay(Color.white.opacity(0.2))

                        // MARK: - Chart
                        WorkoutProgressChart(
                            workoutName: "Body Weight",
                            entries: entries,
                            unitSystemRaw: unitSystemRaw
                        )
                        .frame(height: 220)
                        Spacer()
                        HStack {

                            Label(
                                "Update Weight",
                                systemImage: "scalemass.fill"
                            )
                            .font(.headline)

                            Spacer()

                            Circle()
                                .fill(.green)
                                .frame(width: 10, height: 10)
                        }
                        .foregroundStyle(.white)
                        // MARK: - Hero Weight Ring
                        VStack(spacing: 18) {

                            ZStack {

                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.15),
                                        lineWidth: 18
                                    )
                                    .frame(width: 280, height: 280)

                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        AngularGradient(
                                            colors: [.green, .blue],
                                            center: .center
                                        ),
                                        style: StrokeStyle(
                                            lineWidth: 18,
                                            lineCap: .round
                                        )
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 280, height: 280)

                                VStack(spacing: 10) {

                                    TextField(
                                        "0.0",
                                        text: $newWeightInput
                                    )
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .font(
                                        .system(
                                            size: 60,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .monospacedDigit()
                                    .frame(width: 180)
                                    .focused($isWeightFieldFocused)
//                                    .toolbar {
//                                        ToolbarItemGroup(placement: .keyboard) {
//
//                                            Spacer()
//
//                                            Button("Done") {
//                                                isWeightFieldFocused = false
//                                            }
//                                        }
//                                    }

                                    Text(weightUnit)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.7))

                                    Text("Current Weight")
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }

                            // MARK: - Quick Controls
                            HStack(spacing: 28) {

                                controlButton(
                                    icon: "minus",
                                    color: .orange
                                ) {

                                    let current =
                                    Double(newWeightInput)
                                    ?? Double(currentWeight)
                                    ?? 0

                                    let step =
                                    unitSystem == .imperial
                                    ? 1.0
                                    : 0.5

                                    let next = max(0, current - step)

                                    newWeightInput = formatted(next)
                                }

                                controlButton(
                                    icon: "plus",
                                    color: .blue
                                ) {

                                    let current =
                                    Double(newWeightInput)
                                    ?? Double(currentWeight)
                                    ?? 0

                                    let step =
                                    unitSystem == .imperial
                                    ? 1.0
                                    : 0.5

                                    let next = current + step

                                    newWeightInput = formatted(next)
                                }
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Input Card
                        VStack(alignment: .leading, spacing: 18) {

                            // MARK: - Save Button
                            Button {

                                let trimmed = newWeight

                                guard !trimmed.isEmpty,
                                      Double(trimmed) != nil else {
                                    return
                                }

                                onSave(trimmed)

                                currentWeight = trimmed

                                dismiss()

                            } label: {

                                Label(
                                    "Save Weight",
                                    systemImage: "checkmark.circle.fill"
                                )
                                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 40)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.vertical)
                        }
                    }
                }
                .onTapGesture {
                    isWeightFieldFocused = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if comingFromWidget {
                    ToolbarItem(placement: .topBarLeading) {
                        Button{
                            router.activeScreen = nil
                        } label:{
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarLeading) {

                        Button {

                            dismiss()

                        } label: {

                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                        }
                    }
                }

                ToolbarItem(placement: .principal) {

                    Text("Update Weight")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Helper Button
    func controlButton(
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
    }

    // MARK: - Formatter
    func formatted(_ value: Double) -> String {

        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
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
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                note: "String"
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "183",
                reps: "",
                sets: "",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                note: "String"
            ),
            WorkoutEntry(
                workoutType: "Body Weight",
                weight: "180",
                reps: "",
                sets: "",
                date: Date(),
                note: "String"
            )
        ]

        var body: some View {
            WeightUpdateSheet(
                unitSystem: .imperial,
                weightUnit: "lbs",
                comingFromWidget: false,
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
