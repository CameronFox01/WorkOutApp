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
    @State private var selectedSports: SportsWorkout = .badminton
    @State private var selectedStretch: StretchRoutine = .catCow
    
    @State private var workoutTargetWeights: [String: String] = [:]
    
    private var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
    
    private var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    // Colors
    private let bgColor = Color(hex: "#F3F4F6")
    private let primaryBlue = Color(hex: "#2563EB")
    private let secondaryTeal = Color(hex: "#14B8A6")
    private let accentGreen = Color(hex: "#84CC16")
    
    
    var body: some View {
        ZStack{
            bgColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    generalGoalsCard
                    workoutGoalsSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .onAppear {
                    loadWorkoutGoals()
                }
            }
            
        }
    }
    
    // Fuction for General Section
    private var generalGoalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("General Goals")
                .font(.headline).bold()
                .padding(.bottom, 4)
            
            VStack(spacing: 12) {
                // Target Body Weight row
                HStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .foregroundStyle(primaryBlue)
                        .font(.system(size: 20))
                    
                    Text("Target Body Weight")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    pillField(text: $targetWeight, placeholder: unitSystem == .metric ? "82" : "180", suffix: weightUnit)
                }
                
                // Workouts per Week row
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundStyle(primaryBlue)
                        .font(.system(size: 20))
                    
                    Text("Workouts per Week")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    pillField(
                        text: $targetDaysOfWorkout,
                        placeholder: "4"
                    )
                }
            }
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    //Workout Goal Section - REPLACED AS REQUESTED
    private var workoutGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "dumbbell")
                    .foregroundStyle(primaryBlue)
                Text("Workout Goals")
                    .font(.headline).bold()
            }
            .padding(.horizontal, 2)
            
            VStack(spacing: 12) {
                // Bodyweight (no weight)
                CollapsibleGoalCard(
                    title: "Bodyweight",
                    systemImage: "figure.strengthtraining.functional",
                    selection: $selectedBodyWeight,
                    allCases: BodyweightWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: false
                )
                
                // Push
                CollapsibleGoalCard(
                    title: "Push",
                    systemImage: "arrow.up.forward.circle",
                    selection: $selectedPush,
                    allCases: PushWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Pull
                CollapsibleGoalCard(
                    title: "Pull",
                    systemImage: "arrow.down.backward.circle",
                    selection: $selectedPull,
                    allCases: PullWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Leg
                CollapsibleGoalCard(
                    title: "Leg",
                    systemImage: "figure.strengthtraining.functional",
                    selection: $selectedLeg,
                    allCases: LegWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Glute
                CollapsibleGoalCard(
                    title: "Glute",
                    systemImage: "figure.strengthtraining.traditional",
                    selection: $selectedGlute,
                    allCases: GluteWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Bicep
                CollapsibleGoalCard(
                    title: "Bicep",
                    systemImage: "dumbbell",
                    selection: $selectedBicep,
                    allCases: BicepWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Tricep
                CollapsibleGoalCard(
                    title: "Tricep",
                    systemImage: "bolt.circle",
                    selection: $selectedTricep,
                    allCases: TricepWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: true
                )
                
                // Abs (no weight)
                CollapsibleGoalCard(
                    title: "Abs",
                    systemImage: "figure.core.training",
                    selection: $selectedAbs,
                    allCases: AbsWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: false
                )
                
                // Cardio (distance goal)
                CollapsibleGoalCard(
                    title: "Cardio",
                    systemImage: "figure.run",
                    selection: $selectedCardio,
                    allCases: CardioWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: false,
                    isCardio: true
                )
                
                // Sports (no weight)
                CollapsibleGoalCard(
                    title: "Sports",
                    systemImage: "sportscourt",
                    selection: $selectedSports,
                    allCases: SportsWorkout.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: false
                )
                
                // Stretch (no weight)
                CollapsibleGoalCard(
                    title: "Stretch",
                    systemImage: "figure.cooldown",
                    selection: $selectedStretch,
                    allCases: StretchRoutine.allCases,
                    unitSystem: unitSystem,
                    unitSystemRaw: $unitSystemRaw,
                    targetWeights: $workoutTargetWeights,
                    usesWeight: false
                )
            }
        }
    }
    
    private func collapsedRow(title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    //Old stuff below
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
                ZStack {
                    HStack {
                        Text(selection.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    
                    Picker(title, selection: $selection) {
                        ForEach(allCases) { w in
                            Text(w.rawValue).tag(w)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .opacity(0.01) // 👈 invisible but tappable
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
    
    struct CollapsibleGoalCard<Workout: RawRepresentable & CaseIterable & Identifiable & Hashable>: View where Workout.RawValue == String {
        let title: String
        let systemImage: String
        @Binding var selection: Workout
        let allCases: [Workout]
        let unitSystem: UnitSystem
        @Binding var unitSystemRaw: String
        @Binding var targetWeights: [String: String]
        let usesWeight: Bool
        var isCardio: Bool = false
        
        @State private var isExpanded: Bool = false
        
        private var weightUnit: String { unitSystem == .metric ? "kg" : "lbs" }
        private var distanceUnit: String { unitSystem == .imperial ? "mi" : "km" }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Button { withAnimation(.spring()) { isExpanded.toggle() } } label: {
                    HStack {
                        Label(title, systemImage: systemImage)
                            .font(.headline)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker(title, selection: $selection) {
                            ForEach(allCases) { w in
                                Text(w.rawValue).tag(w)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        // ✅ When selection changes, load any previously saved goal for it
                        .onChange(of: selection) { _, newSelection in
                            let key = "goal_\(newSelection.rawValue)"
                            if let saved = UserDefaults.standard.string(forKey: key) {
                                targetWeights[newSelection.rawValue] = saved
                            }
                        }
                        
                        HStack {
                            if isCardio {
                                pillField(text: Binding<String>(
                                    get: { targetWeights[selection.rawValue] ?? "" },
                                    set: { targetWeights[selection.rawValue] = $0 }
                                ), placeholder: unitSystem == .imperial ? "3" : "5", suffix: distanceUnit)
                            } else if usesWeight {
                                pillField(text: Binding<String>(
                                    get: { targetWeights[selection.rawValue] ?? "" },
                                    set: { targetWeights[selection.rawValue] = $0 }
                                ), placeholder: unitSystem == .metric ? "50" : "110", suffix: weightUnit)
                            } else {
                                pillField(text: Binding<String>(
                                    get: { targetWeights[selection.rawValue] ?? "" },
                                    set: { targetWeights[selection.rawValue] = $0 }
                                ), placeholder: "10")
                            }
                            Spacer(minLength: 0)
                        }
                        
                        gradientButton(title: "Save Goal", systemImage: "checkmark.circle.fill") {
                            let key = "goal_\(selection.rawValue)"
                            UserDefaults.standard.set(targetWeights[selection.rawValue] ?? "", forKey: key)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }
                }
            }
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            // ✅ Load saved value for initial selection when card first expands
            .onAppear {
                let key = "goal_\(selection.rawValue)"
                if let saved = UserDefaults.standard.string(forKey: key) {
                    targetWeights[selection.rawValue] = saved
                }
            }
        }
    }
}

//Color Helper
fileprivate extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b: Double
        switch hexString.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self = Color(red: r, green: g, blue: b)
    }
}

@ViewBuilder
func pillField(
    text: Binding<String>,
    placeholder: String,
    suffix: String? = nil
) -> some View {
    ZStack { // Full-size tap target
        // Invisible overlay to capture taps anywhere in the capsule and focus the field
        Color.clear
            .contentShape(Capsule())
            .onTapGesture {
                // No-op: tap will still allow the TextField to become first responder
            }

        HStack(spacing: 8) {
            // Expand the TextField to take all available width
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .padding(.vertical, 10)
                .padding(.leading, 14)
                .padding(.trailing, suffix == nil ? 14 : 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.clear)

            if let suffix {
                Text(suffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 12)
            }
        }
    }
    .background(Color(.systemGray6), in: Capsule())
    .contentShape(Capsule())
    .padding(.vertical, 0) // keep outer spacing controlled by parent
}

func gradientButton(
    title: String,
    systemImage: String,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        HStack {
            Image(systemName: systemImage)
            Text(title).fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "#14B8A6"), Color(hex: "#84CC16")],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
    .buttonStyle(.plain)
    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
}

#Preview{
    GoalView()
}

//let saved = UserDefaults.standard.string(forKey: "goal_Bench Press") ?? "0"
// use this to grab the goal in the future.

