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
    @State private var selectedCardio: CardioWorkout = .running
    
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
            
            Section(header: Text("Unit System")) {  // ✅ Add unit picker here
                Picker("Unit System", selection: Binding<UnitSystem>(
                    get: {
                        UnitSystem(rawValue: unitSystemRaw) ?? .metric
                    },
                    set: { newValue in
                        let oldUnit = UnitSystem(rawValue: unitSystemRaw) ?? .metric
                        if oldUnit != newValue {
                            unitSystemRaw = newValue.rawValue
                        }
                    }
                )) {
                    ForEach(UnitSystem.allCases, id: \.self) { unit in
                        Text(unit.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            WorkoutSection(title: "Pull Workout", selection: $selectedPull,
                           allCases: PullWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Abs Workouts", selection: $selectedAbs,
                           allCases: AbsWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: false)
            
            WorkoutSection(title: "Leg Workout", selection: $selectedLeg,
                           allCases: LegWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Glute Workout", selection: $selectedGlute,
                           allCases: GluteWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Bicep Workout", selection: $selectedBicep,
                           allCases: BicepWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Tricep Workout", selection: $selectedTricep,
                           allCases: TricepWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Push Workout", selection: $selectedPush,
                           allCases: PushWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: true)
            
            WorkoutSection(title: "Body Weight Workout", selection: $selectedBodyWeight,
                           allCases: BodyweightWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: false)
            
            WorkoutSection(title: "Cardio Workouts", selection: $selectedCardio,
                           allCases: CardioWorkout.allCases, targetWeights: $workoutTargetWeights,
                           unitSystemRaw: $unitSystemRaw, usesWeight: false)
            
            Section {
                Text("Using \(unitSystem.rawValue) units")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Goals")
        .onAppear {
                loadWorkoutGoals()
            }
    }
    
    func loadWorkoutGoals() {
        let allWorkouts = BodyweightWorkout.allCases.map(\.rawValue)
            + PushWorkout.allCases.map(\.rawValue)
            + PullWorkout.allCases.map(\.rawValue)
            + LegWorkout.allCases.map(\.rawValue)
            + GluteWorkout.allCases.map(\.rawValue)
            + BicepWorkout.allCases.map(\.rawValue)
            + TricepWorkout.allCases.map(\.rawValue)
            + AbsWorkout.allCases.map(\.rawValue)
            + CardioWorkout.allCases.map(\.rawValue)

        for workout in allWorkouts {
            let key = "goal_\(workout)"
            if let saved = UserDefaults.standard.string(forKey: key) {
                workoutTargetWeights[workout] = saved
            }
        }
    }
    
    // ✅ Updated WorkoutSection — reacts to unit changes via binding
    struct WorkoutSection<Workout: RawRepresentable & CaseIterable & Identifiable & Hashable>: View where Workout.RawValue == String {
        var title: String
        @Binding var selection: Workout
        var allCases: [Workout]
        @Binding var targetWeights: [String: String]
        @Binding var unitSystemRaw: String  // ✅ Binding instead of plain String
        var usesWeight: Bool                // ✅ Bool instead of optional String
        
        // ✅ Computed reactively from the binding
        private var unitSystem: UnitSystem {
            UnitSystem(rawValue: unitSystemRaw) ?? .metric
        }
        
        private var weightUnit: String {
            unitSystem == .metric ? "kg" : "lbs"
        }
        
        var body: some View {
            Section(header: Text(title)) {
                Picker(title, selection: $selection) {
                    ForEach(allCases) { workout in
                        Text(workout.rawValue).tag(workout)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                
                // ✅ Only show weight field if this workout uses weight
                if usesWeight {
                    TextField(
                        "Target Weight for \(selection.rawValue) (\(weightUnit))",
                        text: bindingForWorkout(selection)
                    )
                    .keyboardType(.decimalPad)
                } else {
                    TextField(
                        "Target for \(selection.rawValue)",
                        text: bindingForWorkout(selection)
                    )
                    .keyboardType(.decimalPad)
                }
                
                Button("Save Goal for \(selection.rawValue)") {
                    saveWorkoutGoal(for: selection)
                }
            }
        }
        
        func bindingForWorkout(_ workout: Workout) -> Binding<String> {
            return Binding<String>(
                get: { targetWeights[workout.rawValue] ?? "" },
                set: { newValue in targetWeights[workout.rawValue] = newValue }
            )
        }
        
        func saveWorkoutGoal(for workout: Workout) {
            let key = "goal_\(workout.rawValue)"
            UserDefaults.standard.set(targetWeights[workout.rawValue], forKey: key)
        }
    }
}

#Preview{
    GoalView()
}

//let saved = UserDefaults.standard.string(forKey: "goal_Bench Press") ?? "0"
// use this to grab the goal in the future.
