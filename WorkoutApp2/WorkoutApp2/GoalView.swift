//
//  GoalView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/6/25.
//

// TODO: I need to get this not to say weight instead maybe say amount. 
import SwiftUI

struct GoalView: View {
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userTargetDaysOfWorkout") private var targetDaysOfWorkout: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    @State private var selectedBodyWeight: BodyweightWorkout = .pushUps
    @State private var selectedPush: PushWorkout = .benchPress
    @State private var selectedPull: PullWorkout = .deadlift
    @State private var selectedLeg: LegWorkout = .squat
    @State private var selectedGlute: GluteWorkout = .hipThrust
    @State private var selectedBicep: BicepWorkout = .bicepCurl
    @State private var selectedTricep: TricepWorkout = .tricepPushdown
    @State private var selectedAbs: AbsWorkout = .sitUps
    
    @State private var workoutTargetWeights: [String: String] = [:]
    
    private var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
    
    private var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    var body: some View {
        Form {
            Section(header: Text("General Goals")) {
                TextField("Target Body Weight (\(weightUnit))", text: $targetWeight)
                    .keyboardType(.decimalPad)
                
                TextField("Workouts per Week", text: $targetDaysOfWorkout)
                    .keyboardType(.numberPad)
            }

            WorkoutSection(
                title: "Pull Workout",
                selection: $selectedPull,
                allCases: PullWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )
            
            WorkoutSection(
                title: "Abs Workouts",
                selection: $selectedAbs,
                allCases: AbsWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: nil
            )

            WorkoutSection(
                title: "Leg Workout",
                selection: $selectedLeg,
                allCases: LegWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )

            WorkoutSection(
                title: "Glute Workout",
                selection: $selectedGlute,
                allCases: GluteWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )

            WorkoutSection(
                title: "Bicep Workout",
                selection: $selectedBicep,
                allCases: BicepWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )

            WorkoutSection(
                title: "Tricep Workout",
                selection: $selectedTricep,
                allCases: TricepWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )
            
            WorkoutSection(
                title: "Push Workout",
                selection: $selectedPush,
                allCases: PushWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: weightUnit
            )
            
            WorkoutSection(
                title: "Body Weight Workout",
                selection: $selectedBodyWeight,
                allCases: BodyweightWorkout.allCases,
                targetWeights: $workoutTargetWeights,
                unit: nil
            )

            Section {
                Text("Using \(unitSystem.rawValue) units")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct WorkoutSection<Workout: RawRepresentable & CaseIterable & Identifiable & Hashable>: View where Workout.RawValue == String {
    var title: String
    @Binding var selection: Workout
    var allCases: [Workout]
    @Binding var targetWeights: [String: String]
    var unit: String?  // ✅ Make this optional

    var body: some View {
        Section(header: Text(title)) {
            Picker(title, selection: $selection) {
                ForEach(allCases) { workout in
                    Text(workout.rawValue).tag(workout)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            
            TextField(
                "Target Weight for \(selection.rawValue)\(unitText)",
                text: bindingForWorkout(selection)
            )
            .keyboardType(.decimalPad)

            Button("Save Goal for \(selection.rawValue)") {
                saveWorkoutGoal(for: selection)
            }
        }
    }
    
    var unitText: String {
        if let unit = unit, !unit.isEmpty {
            return " (\(unit))"
        } else {
            return ""
        }
    }

    func bindingForWorkout(_ workout: Workout) -> Binding<String> {
        return Binding<String>(
            get: {
                targetWeights[workout.rawValue] ?? ""
            },
            set: { newValue in
                targetWeights[workout.rawValue] = newValue
            }
        )
    }

    func saveWorkoutGoal(for workout: Workout) {
        let key = "goal_\(workout.rawValue)"
        UserDefaults.standard.set(targetWeights[workout.rawValue], forKey: key)
    }
}

#Preview{
    GoalView()
}

//let saved = UserDefaults.standard.string(forKey: "goal_Bench Press") ?? "0"
// use this to grab the goal in the future.
