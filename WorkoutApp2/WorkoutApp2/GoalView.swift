//
//  GoalView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/6/25.
//

// TODO: I need to get this not to say weight instead maybe say amount. 
import SwiftUI
import WidgetKit

struct GoalView: View {
    @FocusState private var isEditing: Bool
    @AppStorage("userTargetWeight") private var targetWeight: String = ""
    @AppStorage("userTargetDaysOfWorkout") private var targetDaysOfWorkout: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    @EnvironmentObject var workoutData: WorkoutData
    
    @State private var selectedBodyWeight: BodyweightWorkout = .airSquats
    @State private var selectedPush: PushWorkout = .ArnoldPress
    @State private var selectedPull: PullWorkout = .alternatingDumbbellRow
    @State private var selectedLeg: LegWorkout = .hipAdductorClosing
    @State private var selectedGlute: GluteWorkout = .backwardLunge
    @State private var selectedBicep: BicepWorkout = .alternatingDumbbellCurl
    @State private var selectedTricep: TricepWorkout = .bandedPushdown
    @State private var selectedAbs: AbsWorkout = .abdominalVacuum
    @State private var selectedDistanceCardio: DistanceCardioWorkout = .briskWalking
    @State private var selectedTimeCardio: TimeCardioWorkout = .battleRopes
    @State private var selectedSports: SportsWorkout = .archery
    @State private var selectedStretch: StretchRoutine = .ankleCircles
    
    @State private var workoutTargetWeights: [String: String] = [:]
    
    private var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
    
    private var weightUnit: String {
        unitSystem == .metric ? "kg" : "lbs"
    }
    
    // Colors
    
    private let primaryBlue = Color(hex: "#2563EB")
    private let secondaryTeal = Color(hex: "#14B8A6")
    private let accentGreen = Color(hex: "#84CC16")
    
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color.blue.opacity(1.0),
                    Color.cyan.opacity(0.6),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    generalGoalsCard
                    workoutGoalsSection
                    NavigationLink {
                        
                        AchievedGoalsView(
                            achievedGoals: achievedGoals,
                            comingfromWidget: false
                        )
                        
                    } label: {
                        
                        HStack {
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            
                            VStack(alignment:.leading) {
                                
                                Text("Achieved Goals")
                                    .font(.headline)
                                
                                Text("View completed goals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                            }
                            
                            Spacer()
                            
                            Image(systemName:"chevron.right")
                                .foregroundStyle(.secondary)
                            
                        }
                        .padding()
                        .background(
                            Color(.secondarySystemBackground),
                            in: RoundedRectangle(
                                cornerRadius:16
                            )
                        )
                        
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        MilestonesView(
                            milestones: achievedMilestones,
                            comingfromWidget: false
                        )
                    } label: {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment:.leading){
                                Text("Milestones Achieved")
                                    .font(.headline)
                                Text("View completed milestones")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName:"chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius:16)
                        )
                    }
                    .buttonStyle(.plain)
                    .scrollDismissesKeyboard(.interactively)
                }
                .onTapGesture {
                    isEditing = false
                }
                .toolbar{
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { isEditing = false }
                    }
                }
            }
            .onAppear {
                loadWorkoutGoals()
                loadAchievedGoals()
                loadAchievedMilestones()
                let goal = Int(targetDaysOfWorkout) ?? 0
                let challengeEnabled = UserDefaults.standard.bool(forKey: "workoutChallengeReminder")
                let notifsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

                if challengeEnabled && notifsEnabled {
                    NotificationHandler.shared.scheduleWeeklyWorkoutChallengeNotifications(goalDays: goal)
                }
                
                UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")?.set(targetDaysOfWorkout, forKey: "userTargetDaysOfWorkout")
            }
            .onChange(of: targetDaysOfWorkout) { _, newValue in
                UserDefaults(suiteName: "group.Fox-Studios.WorkoutApp2")?.set(newValue, forKey: "userTargetDaysOfWorkout")
                WidgetCenter.shared.reloadAllTimelines() 
                
                let goal = Int(targetDaysOfWorkout) ?? 0
                let challengeEnabled = UserDefaults.standard.bool(forKey: "workoutChallengeReminder")
                let notifsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

                if challengeEnabled && notifsEnabled {
                    NotificationHandler.shared.scheduleWeeklyWorkoutChallengeNotifications(goalDays: goal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Set Goals")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
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
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        pillField(text: $targetWeight,
                                  placeholder: unitSystem == .metric ? "82" : "180",
                                  suffix: weightUnit,
                                  focus: $isEditing
                        )
                        //.submitScope()
                    }
                    
                    // Workouts per Week row
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Days", selection: $targetDaysOfWorkout) {
                                ForEach(["1","2", "3", "4", "5", "6", "7"], id: \.self) { day in
                                    Text(day).tag(day)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundStyle(primaryBlue)
                            Text("Workouts per Week")
                                .foregroundStyle(.primary)
                        }
                        .font(.headline)
                        .textCase(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .shadow(color: Color.white.opacity(0.03), radius: 1, x: 0, y: 0)
            }
        }
        
        //Workout Goal Section
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
                        systemImage: "figure.cross.training",
                        selection: $selectedBodyWeight,
                        allCases: BodyweightWorkout.allCases,
                        unitSystem: unitSystem,
                        unitSystemRaw: $unitSystemRaw,
                        targetWeights: $workoutTargetWeights,
                        usesWeight: false,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: false,
                        symbolColor: primaryBlue,
                        focus: $isEditing
                    )
                    
                    // Cardio (distance goal)
                    CollapsibleGoalCard(
                        title: "Distance Cardio",
                        systemImage: "figure.run",
                        selection: $selectedDistanceCardio,
                        allCases: DistanceCardioWorkout.allCases,
                        unitSystem: unitSystem,
                        unitSystemRaw: $unitSystemRaw,
                        targetWeights: $workoutTargetWeights,
                        usesWeight: false,
                        isDistanceCardio: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
                    )
                    
                    CollapsibleGoalCard(
                        title: "Time Cardio",
                        systemImage: "figure.dance",
                        selection: $selectedTimeCardio,
                        allCases: TimeCardioWorkout.allCases,
                        unitSystem: unitSystem,
                        unitSystemRaw: $unitSystemRaw,
                        targetWeights: $workoutTargetWeights,
                        usesWeight: false,
                        isTimeCardio: true,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: false,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
                        usesWeight: false,
                        symbolColor: primaryBlue,
                        focus: $isEditing
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
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            .shadow(color: Color.white.opacity(0.03), radius: 1, x: 0, y: 0)
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
            + DistanceCardioWorkout.allCases.map(\.rawValue)
            
            for workout in allWorkouts {
                let key = "goal_\(workout)"
                if let saved = UserDefaults.standard.string(forKey: key) {
                    workoutTargetWeights[workout] = saved
                }
            }
        }
        
        @State private var achievedGoals: [AchievedGoal] = []
        
        private func loadAchievedGoals() {
            // Build a comprehensive list of workout names (same as loadWorkoutGoals)
            let allWorkouts = BodyweightWorkout.allCases.map(\.rawValue)
            + PushWorkout.allCases.map(\.rawValue)
            + PullWorkout.allCases.map(\.rawValue)
            + LegWorkout.allCases.map(\.rawValue)
            + GluteWorkout.allCases.map(\.rawValue)
            + BicepWorkout.allCases.map(\.rawValue)
            + TricepWorkout.allCases.map(\.rawValue)
            + AbsWorkout.allCases.map(\.rawValue)
            + DistanceCardioWorkout.allCases.map(\.rawValue)
            + TimeCardioWorkout.allCases.map(\.rawValue)
            + SportsWorkout.allCases.map(\.rawValue)
            + StretchRoutine.allCases.map(\.rawValue)
            
            var results: [AchievedGoal] = []
            
            for workout in allWorkouts {
                let goalKey = "goal_\(workout)"
                let completedKey = "goalReached_\(workout)" // matches your WorkoutData.checkGoalAchieved(for:)
                
                guard let goalValue = UserDefaults.standard.string(forKey: goalKey), !goalValue.isEmpty else {
                    continue
                }
                
                let reached = UserDefaults.standard.bool(forKey: completedKey)
                if reached {
                    results.append(AchievedGoal(workout: workout, target: goalValue, dateReached: nil))
                }
            }
            
            // Optionally sort alphabetically
            achievedGoals = results.sorted { $0.workout.localizedCaseInsensitiveCompare($1.workout) == .orderedAscending }
        }
    
        @State private var achievedMilestones: [Milestone] = []

        private func loadAchievedMilestones() {
            let completedData = UserDefaults.standard.data(forKey: "completedMilestonesData") ?? Data()
            let completed = (try? JSONDecoder().decode(Set<String>.self, from: completedData)) ?? []

            var results: [Milestone] = []

            for key in completed {
                if key.hasPrefix("workout_") {
                    let number = key.replacingOccurrences(of: "workout_", with: "")
                    results.append(
                        Milestone(
                            title: "\(number) Workouts",
                            description: "Completed \(number) workouts",
                            icon: "dumbbell.fill",
                            dateReached: nil
                        )
                    )
                } else if key.hasPrefix("days_") {
                    let number = key.replacingOccurrences(of: "days_", with: "")
                    results.append(
                        Milestone(
                            title: "\(number) Workout Days",
                            description: "Worked out on \(number) different days",
                            icon: "calendar",
                            dateReached: nil
                        )
                    )
                }
            }

            achievedMilestones = results.sorted { $0.title < $1.title }
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
                        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
                        
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
            var isDistanceCardio: Bool = false
            var isTimeCardio: Bool = false
            let symbolColor: Color // ✅ now a parameter
            let focus: FocusState<Bool>.Binding
            
            
            @State private var isExpanded: Bool = false
            
            private var weightUnit: String { unitSystem == .metric ? "kg" : "lbs" }
            private var distanceUnit: String { unitSystem == .imperial ? "mi" : "km" }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation(.spring()) {
                            isExpanded.toggle() } } label: {
                                HStack {
                                    Image(systemName: systemImage)
                                        .foregroundColor(symbolColor) // 👈 only icon
                                    Text(title)
                                        .font(.headline)
                                        .foregroundColor(.primary) // keep text color normal
                                    Spacer()
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle())
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
                                if isDistanceCardio {
                                    pillField(text: Binding<String>(
                                        get: { targetWeights[selection.rawValue] ?? "" },
                                        set: { targetWeights[selection.rawValue] = $0 }
                                    ), placeholder: unitSystem == .imperial ? "3" : "5",
                                              suffix: distanceUnit,
                                              focus: focus
                                    )
                                    
                                } else if usesWeight {
                                    pillField(text: Binding<String>(
                                        get: { targetWeights[selection.rawValue] ?? "" },
                                        set: { targetWeights[selection.rawValue] = $0 }
                                    ), placeholder: unitSystem == .metric ? "50" : "110",
                                              suffix: weightUnit,
                                              focus: focus
                                    )
                                } else if isTimeCardio {
                                    pillField(text: Binding<String>(
                                        get: { targetWeights[selection.rawValue] ?? "" },
                                        set: { targetWeights[selection.rawValue] = $0 }
                                    ), placeholder: "30",
                                              suffix: "min",
                                              focus: focus
                                    )
                                }else {
                                    pillField(text: Binding<String>(
                                        get: { targetWeights[selection.rawValue] ?? "" },
                                        set: { targetWeights[selection.rawValue] = $0 }
                                    ), placeholder: "10",
                                              suffix: "",
                                              focus: focus
                                    )
                                }
                                Spacer(minLength: 0)
                            }
                            
                            gradientButton(title: "Save Goal", systemImage: "checkmark.circle.fill") {
                                let key = "goal_\(selection.rawValue)"
                                UserDefaults.standard.set(targetWeights[selection.rawValue] ?? "", forKey: key)
                                UserDefaults.standard.set(false, forKey: "goalReached_\(selection.rawValue)")
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .shadow(color: Color.white.opacity(0.03), radius: 1, x: 0, y: 0)
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
        suffix: String? = nil,
        focus: FocusState<Bool>.Binding
    ) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text)
                .focused(focus) // Keep this
                .keyboardType(.decimalPad)
                .submitLabel(.done)
                .padding(.vertical, 10)
                .padding(.leading, 14)
                .padding(.trailing, suffix == nil ? 14 : 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let suffix {
                Text(suffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 12)
            }
        }
        // REMOVE .submitScope() from here and in the calling code
        .background(Color(.secondarySystemFill), in: Capsule())
        .contentShape(Capsule())
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

#Preview {
    NavigationStack {
        GoalView()
            .environmentObject(WorkoutData())
    }
}

//let saved = UserDefaults.standard.string(forKey: "goal_Bench Press") ?? "0"
// use this to grab the goal in the future.

